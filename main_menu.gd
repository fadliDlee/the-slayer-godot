extends Control

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_tombol_mulai_pressed():
	# Perintah untuk membuka cutscene cerita saat tombol mulai ditekan
	get_tree().change_scene_to_file("res://intro_story.tscn")

func _on_tombol_keluar_pressed():
	print("LOG: Game ditutup.")
	get_tree().quit()
