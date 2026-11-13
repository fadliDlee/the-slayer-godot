extends CanvasLayer

func _on_button_pressed():
	# Memastikan waktu berjalan normal kembali
	get_tree().paused = false 
	
	# Mereset / memuat ulang scene yang sedang aktif dari awal
	get_tree().reload_current_scene()
