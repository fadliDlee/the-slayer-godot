extends CanvasLayer

func _on_button_pressed():
	# 1. Jalankan waktu kembali agar game tidak freeze saat kembali ke menu
	get_tree().paused = false 
	
	# 2. Berpindah ke scene Menu Utama
	# agar sama persis dengan nama file menu utama milikmu!
	get_tree().change_scene_to_file("res://main_menu.tscn")
