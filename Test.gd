extends Node

func _ready() -> void:
	$TextEdit.text = $Sprite.material.shader.code
	_on_TextEdit_text_changed()

func _on_TextEdit_text_changed() -> void:
	var string : String = $TextEdit.text
	
	$Sprite.material.shader.set_code(string)
	
	$TextEdit2.text = $Sprite.material.shader.get_preprocessed_code()
	$TextEdit2.cursor_set_line($TextEdit.cursor_get_line())
	$TextEdit2.cursor_set_column($TextEdit.cursor_get_column())