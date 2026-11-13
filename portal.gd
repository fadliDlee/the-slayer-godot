extends Area2D

# Fitur @export akan memunculkan kolom baru di panel Inspector sebelah kanan!
@export var level_tujuan: String = "res://level_3.tscn" 

# --- EVENT-DRIVEN: SENSOR SENTUHAN ---
func _on_body_entered(body):
	# Cek apakah yang menyentuh portal adalah Player
	if body.name == "player":
		print("LOG: Memasuki gerbang! Menuju ke: ", level_tujuan)
		
		# Perintah Godot untuk menghapus level sekarang dan memuat level baru
		get_tree().change_scene_to_file(level_tujuan)
