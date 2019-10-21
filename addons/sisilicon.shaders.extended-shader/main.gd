tool
extends EditorPlugin

const ExtendedShader = preload("ExtendedShader.gd")

var shader_editor
var button

func _enter_tree():
	add_custom_type("ExtendedShader", "Shader", ExtendedShader, preload("res://icon.png"))
	print("ExtendedShader has entered the editor.")
#	shader_editor = memnew(ShaderEditor(p_node))
#
#	shader_editor.set_custom_minimum_size(Size2(0, 300))
#	button = editor.add_bottom_panel_item(TTR("Shader"), shader_editor)
#	button.hide()

func _exit_tree():
	remove_custom_type("ExtendedShader")
	print("ExtendedShader has exited the editor.")

func edit(object : Object) -> void:
	var shader := object as ExtendedShader
#	shader_editor.edit(s)

func handles(object : Object) -> bool:
	var shader := object as ExtendedShader
	return shader != null

#func make_visible(visible : bool) -> void:
#	if visible:
#		button.show()
#		editor.make_bottom_panel_item_visible(shader_editor)
#	else:
#		button.hide()
#		if shader_editor.is_visible_in_tree():
#			editor.hide_bottom_panel()
#		shader_editor.apply_shaders()
#
#func selected_notify() -> void:
#	shader_editor.ensure_select_current()
#
#func save_external_data() -> void:
#	shader_editor.save_external_data()
#
#func apply_changes() -> void:
#	shader_editor.apply_shaders()
