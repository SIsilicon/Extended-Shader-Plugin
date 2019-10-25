tool
extends ResourceFormatSaver
class_name ResourceSaverExtShader

const ExtendedShader = preload("ExtendedShader.gd")

func get_recognized_extensions(resource : Resource) -> PoolStringArray:
	return PoolStringArray(["extshader"])

func recognize(resource : Resource) -> bool:
	return resource is ExtendedShader

func save(path : String, resource : Resource, flags : int) -> int:
	var file = File.new()
	file.open(path, File.WRITE)
	if file.get_error():
		return file.get_error()
	
	file.store_string((resource as ExtendedShader).get_raw_code())
	file.store_var((resource as ExtendedShader).defines)
	file.close()
	
	return OK