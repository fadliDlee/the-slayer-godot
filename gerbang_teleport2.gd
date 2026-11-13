extends Area2D

var aktif = false

func _ready():
	hide() # Sembunyi saat awal game
	# KONEKSI OTOMATIS: Menyambungkan tabrakan ke fungsi di bawah via kode
	self.body_entered.connect(_on_body_entered)

func buka_gerbang():
	aktif = true
	show() # Munculkan portal
	print("LOG: Gerbang sekarang AKTIF!")

func _on_body_entered(body):
	print("Menyentuh gerbang: ", body.name) # Cek siapa yang menyentuh
	print("Status gerbang: ", aktif) # Cek apakah gerbang sudah aktif

	if aktif and body.name == "player":
		get_tree().change_scene_to_file("res://level_3.tscn")
