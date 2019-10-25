tool
extends EditorPlugin

const ExtendedShader = preload("ExtendedShader.gd")

var shader : Shader
var shader_editor : Control
var button : Button

func _enter_tree():
	add_custom_type("ExtendedShader", "Shader", ExtendedShader, preload("icon_extended_shader.svg"))
	print("ExtendedShader has entered the editor.")
	shader_editor = preload("ExtShaderEditor.tscn").instance()
	
	shader_editor.set_custom_minimum_size(Vector2(0, 300))
	button = add_control_to_bottom_panel(shader_editor, "ExtendedShader")
	button.hide()
	
	for but in button.get_parent().get_children():
		if but.text == "Output":
			print(but.get_children())
			break

func _exit_tree():
	remove_custom_type("ExtendedShader")
	remove_control_from_bottom_panel(shader_editor)
	print("ExtendedShader has exited the editor.")

func edit(object : Object) -> void:
	shader = object as ExtendedShader
	shader_editor.edit(shader)

func handles(object : Object) -> bool:
	return object is ExtendedShader

func make_visible(visible : bool) -> void:
	if visible:
		button.show()
		make_bottom_panel_item_visible(shader_editor)
	else:
		button.hide()
		if shader_editor.is_visible_in_tree():
			hide_bottom_panel()
		shader_editor.apply_shaders()

func selected_notify() -> void:
	shader_editor.ensure_select_current()

func save_external_data() -> void:
	shader_editor.save_external_data()

func apply_changes() -> void:
	shader_editor.apply_shaders()
