tool
extends Control

enum {FIND, FIND_NEXT, FIND_PREVIOUS, REPLACE, GOTO_LINE,
		UNDO, REDO, CUT, COPY, PASTE, SELECT_ALL, MOVE_UP,
		MOVE_DOWN, INDENT_LEFT, INDENT_RIGHT, DELETE_LINE,
		TOGGLE_COMMENT, CLONE_DOWN, COMPLETE_SYMBOL
}

const ExtendedShader = preload("ExtendedShader.gd")

onready var text_edit := $TextEdit

var had_focus := false
var shader : ExtendedShader

func _ready() -> void:
	var search : PopupMenu = $Tools/Search.get_popup()
	var edit : PopupMenu = $Tools/Edit.get_popup()
	search.connect("id_pressed", self, "_on_Menu_item_pressed")
	edit.connect("id_pressed", self, "_on_Menu_item_pressed")
	
#	search.set_item_shortcut(search.get_item_index(FIND), shortcut(KEY_F, true, false, false))
#	search.set_item_shortcut(search.get_item_index(FIND_NEXT), shortcut(KEY_F3, false, false, false))
#	search.set_item_shortcut(search.get_item_index(FIND_PREVIOUS), shortcut(KEY_F3, false, true, false))
#	search.set_item_shortcut(search.get_item_index(REPLACE), shortcut(KEY_R, true, false, false))
#	search.set_item_shortcut(search.get_item_index(GOTO_LINE), shortcut(KEY_L, true, false, false))
#
#	edit.set_item_shortcut(edit.get_item_index(UNDO), shortcut(KEY_Z, true, false, false))
#	edit.set_item_shortcut(edit.get_item_index(REDO), shortcut(KEY_Y, true, false, false))
#	edit.set_item_shortcut(edit.get_item_index(CUT), shortcut(KEY_X, true, false, false))
#	edit.set_item_shortcut(edit.get_item_index(COPY), shortcut(KEY_C, true, false, false))
#	edit.set_item_shortcut(edit.get_item_index(PASTE), shortcut(KEY_V, true, false, false))
#	edit.set_item_shortcut(edit.get_item_index(SELECT_ALL), shortcut(KEY_A, true, false, false))
#
#	edit.set_item_shortcut(edit.get_item_index(MOVE_UP), shortcut(KEY_UP, false, false, true))
#	edit.set_item_shortcut(edit.get_item_index(MOVE_DOWN), shortcut(KEY_DOWN, false, false, true))
#	edit.set_item_shortcut(edit.get_item_index(DELETE_LINE), shortcut(KEY_K, true, true, false))
#	edit.set_item_shortcut(edit.get_item_index(TOGGLE_COMMENT), shortcut(KEY_K, true, false, false))
#	edit.set_item_shortcut(edit.get_item_index(CLONE_DOWN), shortcut(KEY_B, true, false, false))
#
#	edit.set_item_shortcut(edit.get_item_index(COMPLETE_SYMBOL), shortcut(KEY_SPACE, true, false, false))
	
	edit(shader)


func save_external_data() -> void:
	if not shader:
		return
	
	apply_shaders()
	if shader.resource_path != "" && shader.resource_path.find("local://") == -1 && shader.resource_path.find("::") == -1:
		#external shader, save it
		ResourceSaver.save(shader.resource_path, shader)

func edit(shader : ExtendedShader) -> void:
	if self.shader != shader:
		self.shader = shader
		text_edit = $TextEdit
		
		_on_TextEdit_cursor_changed()
		text_edit.text = shader.raw_code
		apply_shaders()
		
		if had_focus:
			text_edit.grab_focus()
			had_focus = false

func apply_shaders() -> void:
	if text_edit and shader:
		var shader_code := shader.get_raw_code()
		var editor_code : String = text_edit.text
		shader.set_code(editor_code)
		
		had_focus = true


func _on_TextEdit_cursor_changed():
	$Cursor.text = "(    " + str(text_edit.cursor_get_column()) + \
	",    " + str(text_edit.cursor_get_line()) + ")"

func _on_TextEdit_text_changed():
	$Timer.start()

func _on_Timer_timeout():
	apply_shaders()

func _on_Menu_item_pressed(ID : int) -> void:
	
	match ID:
#		FIND: pass
#		FIND_NEXT: pass
#		FIND_PREVIOUS: pass
#		REPLACE: pass
#		GOTO_LINE: pass
		
		UNDO: text_edit.undo()
		REDO: text_edit.redo()
		
		CUT: text_edit.cut()
		COPY: text_edit.copy()
		PASTE: text_edit.paste()
		
		SELECT_ALL: text_edit.select_all()
		
#		MOVE_UP: pass
#		MOVE_DOWN: pass
#		INDENT_LEFT: pass
#		INDENT_RIGHT: pass
#		DELETE_LINE: pass
#		TOGGLE_COMMENT: pass
#		CLONE_DOWN: pass
#		
#		COMPLETE_SYMBOL: pass
		
		_:
			printerr("Sorry! This feature is currently unsupported. :(")


func shortcut(scancode : int, ctrl : bool = false, shift : bool = false, alt : bool = false) -> ShortCut:
	var shortcut := ShortCut.new()
	var input := InputEventKey.new()
	input.scancode = scancode
	input.control = ctrl
	input.shift = shift
	input.alt = alt
	shortcut.shortcut = input
	
	return shortcut
