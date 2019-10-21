tool
extends Shader

var raw_code

func set_code(value : String) -> void:
	raw_code = value
	
	code = remove_comments(raw_code)
	.set_code(process_directives(code))

func get_code() -> String:
	return raw_code

func get_preprocessed_code() -> String:
	return code

func remove_comments(string : String) -> String:
	var comment := create_reg_exp("(//[^\\n]*\\n?)|(/\\*[\\S\\s]*\\*/)")
	
	return comment.sub(string, "", true)

func process_directives(string : String) -> String:
	var lines : PoolStringArray = string.split("\n")
	
	var defines := {}
	var if_stack := []
	
	var define_mac := create_reg_exp("[ ]*#[ ]*define[ ]+(?<name>\\w[\\d\\w]*)[ ]*(?<value>[^\\\\]+)?")
	var define_func := create_reg_exp("\\(([ ]*[\\w]+[ ]*,*[ ]*)+\\)")
	
	var ifdef := create_reg_exp("[ ]*#[ ]*if(?<define>(?<negated>n)?def)?[ ]+(?<expression>[^\\\\]+)")
	var elifd := create_reg_exp("[ ]*#[ ]*elif[ ]+(?<condition>[^\\\\]+)")
	var else_endif := create_reg_exp("[ ]*#[ ]*((?<else>else)|(endif))")
	
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
					params = params.replace(" ", "").replace("(", "").replace(")", "")
					params = params.trim_suffix(",")
					params = params.split(",")
					
					value = {"params":params, "func":Func}
			
			defines[name] = value if value else 1
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
			
			print(stack)
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
			for define in defines:
				lines[line_num] = line.replace(define, str(defines[define]))
			
			line_num += 1
	
#	if not defines.empty():
#		print(defines)
	
	string = ""
	for line in lines:
		string += line + "\n"
	
	return string

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
	
	for define in defines:
		condition = condition.replace(define, str(defines[define]))
	
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

