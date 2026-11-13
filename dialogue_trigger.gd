extends Area2D

@export var ui_dialog_path: NodePath
@export var isi_cerita: Array[String]
var sudah_disentuh: bool = false

func _ready():
	# Menyambungkan sinyal tabrakan secara otomatis
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Mengecek apakah yang menabrak memiliki nama persis "player" (huruf kecil)
	if body.name == "player" and not sudah_disentuh:
		sudah_disentuh = true
		
		var ui_node = get_node(ui_dialog_path)
		if ui_node:
			ui_node.start_dialog(isi_cerita)
		else:
			print("ERROR: Node UI tidak ditemukan! Cek UI Dialog Path di Inspector.")
