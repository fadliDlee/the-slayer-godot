extends Area2D

func _ready():
	# Menyambungkan sinyal tabrakan
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Mengecek apakah yang menyentuh duri adalah karakter utama
	if body.name == "player":
		print("LOG: Player terkena duri mematikan! Merestart Level...")
		
		# Perintah sakti untuk mereset ulang seluruh level ke kondisi awal
		get_tree().reload_current_scene()
