tool
extends Shader

export var defines := {} setget set_defines

var raw_code := "" setget set_code, get_raw_code

func set_defines(value : Dictionary) -> void:
	if value:
		defines = value
	else:
		defines = {}
	update_code()

func set_code(value : String) -> void:
	raw_code = value
	update_code()

func get_raw_code() -> String:
	return raw_code

func update_code():
	var new_code = expand_includes(raw_code)
	new_code = remove_comments(new_code)
	.set_code(process_directives(new_code))

func expand_includes(string : String) -> String:
	var include := create_reg_exp("[ ]*#[ ]*include[ ]+\"(?<filepath>[ \\d\\w\\-:/.\\(\\)]+)\"")
	
	var lines : PoolStringArray = string.split("\n")
	var line_num := 0
	while line_num < lines.size():
		var line := lines[line_num]
		
		var Match := include.search(line)
		if Match:
			var path := Match.get_string("filepath")
			lines.remove(line_num)
			if ResourceLoader.exists(path):
				var resource := load(path)
				
				var sub_code : String
#				print(path.get_extension())
				if resource is Shader:
					sub_code = resource.code
				else:
					printerr("You can only include shader files.")
				
				sub_code = expand_includes(sub_code).trim_suffix("\n")
				lines.insert(line_num, sub_code)
				line_num += 1
			continue
		
		line_num += 1
	
	string = ""
	for line in lines:
		string += line + "\n"
	
	return string

func remove_comments(string : String) -> String:
	var comment := create_reg_exp("(//[^\\n]*\\n?)|(/\\*[\\S\\s]*\\*/)")
	return comment.sub(string, "", true)

func process_directives(string : String) -> String:
	var define_mac := create_reg_exp("[ ]*#[ ]*define[ ]+(?<name>\\w[\\d\\w]*)[ ]*(?<value>[^\\\\]+)?")
	var define_func := create_reg_exp("\\(([ ]*[\\w]+[ ]*,*[ ]*)+\\)")
	var undefine := create_reg_exp("[ ]*#[ ]*undef[ ]+(?<name>\\w[\\d\\w]*)")
	
	var ifdef := create_reg_exp("[ ]*#[ ]*if(?<define>(?<negated>n)?def)?[ ]+(?<expression>[^\\\\]+)")
	var elifd := create_reg_exp("[ ]*#[ ]*elif[ ]+(?<condition>[^\\\\]+)")
	var else_endif := create_reg_exp("[ ]*#[ ]*((?<else>else)|(endif))")
	
	var defines := self.defines.duplicate()
	var if_stack := []
	
	var lines : PoolStringArray = string.split("\n")
	var line_num := 0
	while line_num < lines.size():
		var line := lines[line_num]
		
		var Match := define_mac.search(line)
		if Match:
			var name := Match.get_string("name")
			var value = Match.get_string("value")
			
			if value:
				var params = define_func.search(value)
				params = params.get_string() if params else null
				
				if params:
					var Func = value.replace(params, "")
					Func = replace_defines(Func, defines)
					params = params.replace(" ", "").replace("(", "").replace(")", "")
					params = params.trim_suffix(",")
					params = params.split(",")
					
					value = {"params":params, "func":Func}
			
			defines[name] = value if value else 1
			lines.remove(line_num)
			continue
		
		Match = undefine.search(line)
		if Match:
			var name := Match.get_string("name")
			
			if defines.has(name):
				defines.erase(name)
			lines.remove(line_num)
			
			continue
		
		Match = ifdef.search(line)
		if Match:
			var negated := Match.get_start("negated") != -1
			
			var state : bool
			if Match.get_string("define"):
				var name := Match.get_string("expression")
				state = defines.has(name)
			else:
				var condition = Match.get_string("expression")
				state = evaluate_condition(condition, defines)
			
			state = ((not state) if negated else state)
			if_stack.push_front({"line":line_num, "state":state})
			lines.remove(line_num)
			continue
		
		Match = else_endif.search(line)
		if Match:
			var stack = if_stack.pop_front()
			if not stack:
				printerr("Uneven amount of ifs and endifs!")
				break
			
			lines.remove(line_num)
			
			if not stack.state:
				for l in range(stack.line, line_num):
					lines.remove(stack.line)
					line_num -= 1
			
			var is_else = Match.get_start("else") != -1
			if is_else:
				if_stack.push_front({"line":line_num, "state":not stack.state})
			
			continue
		
		Match = elifd.search(line)
		if Match:
			var stack = if_stack.pop_front()
			if not stack:
				printerr("Uneven amount of ifs and endifs!")
				break
			
			lines.remove(line_num)
			
			if not stack.state:
				for l in range(stack.line, line_num):
					lines.remove(stack.line)
					line_num -= 1
			
			var condition = Match.get_string("condition")
			var state = evaluate_condition(condition, defines)
			if_stack.push_front({"line":line_num, "state":state})
			
			continue
		
		if not Match:
			lines[line_num] = replace_defines(line, defines)
			line_num += 1
	
#	if not defines.empty():
#		print(defines)
	
	string = ""
	for line in lines:
		string += line + "\n"
	
	return string

func replace_defines(line : String, defines : Dictionary) -> String:
	for define in defines:
		var define_var := create_reg_exp("[^\\d\\w]"+define+"[^\\d\\w]")
		var define_func := create_reg_exp("[^\\d\\w]"+define+"[ ]*\\((?<vars>[^\\(\\)\\\\]+)\\)")
		
		if typeof(defines[define]) == TYPE_DICTIONARY: # If the macro is a function
			var def_match := define_func.search(line)
			while def_match:
				var params : Array = defines[define]["params"]
				var function : String = defines[define]["func"]
				
				var vars_string := def_match.get_string("vars")
				var vars := vars_string.split(",")
				
				var params_dict = {}
				for i in params.size():
					params_dict[params[i]] = vars[i]
				
				line.erase(def_match.get_start() + 1, def_match.get_end() - def_match.get_start() - 1)
				line = line.insert(def_match.get_start() + 1, replace_defines(function, params_dict))
				
				def_match = define_var.search(line)
		else:
			var def_match := define_var.search(line)
			while def_match:
				line.erase(def_match.get_start() + 1, def_match.get_end() - def_match.get_start() - 2)
				line = line.insert(def_match.get_start() + 1, defines[define] if defines[define] else 1)
				def_match = define_var.search(line)
	
	return line

func evaluate_condition(condition : String, defines : Dictionary) -> bool:
	var defined := create_reg_exp("defined[ ]*\\([ ]*(?<macro>\\w[\\w\\d]+)[ ]*\\)")
	
	var matches := defined.search_all(condition)
	for i in range(matches.size() - 1, -1, -1):
		var regexmatch : RegExMatch = matches[i]
		var macro := regexmatch.get_string("macro")
		
		var index := regexmatch.get_start()
		var length := regexmatch.get_end() - index
		
		condition.erase(index, length)
		condition = condition.insert(index, "true" if defines.has(macro) else "false")
	
	condition = replace_defines(condition, defines)
	
	var expression := Expression.new()
	var error := expression.parse(condition)
	if error:
		printerr("A condition failed to be parsed: " + condition + " : " + str(error))
		return false
	
	var boolean : bool = expression.execute()
	
	return false if boolean == null else boolean

func create_reg_exp(string : String) -> RegEx:
	var reg_exp := RegEx.new()
	reg_exp.compile(string)
	
	if not reg_exp.is_valid():
		printerr("'" + string + "' is not a valid regular expression!")
	
	return reg_exp

