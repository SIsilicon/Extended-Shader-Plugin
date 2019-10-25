tool
extends ResourceFormatLoader
class_name ResourceLoaderExtShader

const ExtendedShader = preload("ExtendedShader.gd")

func get_dependencies(path : String, add_types : String) -> void:
	print(path + ", " + add_types)
	pass

func get_recognized_extensions() -> PoolStringArray:
	return PoolStringArray(["extshader"])

func get_resource_type(path : String) -> String:
	if path.ends_with(".extshader"):
		return "Shader"
	else:
		return ""

func handles_type(typename : String) -> bool:
	return typename == "Shader"

func load(path : String, original_path : String):
	var file = File.new()
	file.open(path, File.READ)
	if file.get_error():
		return file.get_error()
	
	var code : String = file.get_as_text()
	var defines : Dictionary = file.get_var()
	file.close()
	
	if code:
		var shader := ExtendedShader.new()
		shader.set_code(code)
		if defines:
			shader.defines = defines
		return shader
	else:
		return ERR_PARSE_ERROR