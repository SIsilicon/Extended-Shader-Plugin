tool
extends Node

func _ready() -> void:
	update_text()

func update_text() -> void:
	$TextEdit.text = $Sprite.material.shader.get_raw_code()
	
	$TextEdit2.text = $Sprite.material.shader.get_code()
	$TextEdit2.cursor_set_line($TextEdit.cursor_get_line())
	$TextEdit2.cursor_set_column($TextEdit.cursor_get_column())

func _on_TextEdit_text_changed() -> void:
	$Timer.start()

func _on_Timer_timeout() -> void:
	update_text()
