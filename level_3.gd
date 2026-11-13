extends Node2D

func _ready():
	# Matikan portal di awal permainan
	$PortalKeluar/CollisionShape2D.set_deferred("disabled", true)

func _process(delta):
	# Mengecek secara terus-menerus apakah Bos sudah mati/hilang
	if not has_node("BossTengkorak"): 
		# Jika Bos hilang (queue_free), aktifkan portal!
		$PortalKeluar/CollisionShape2D.set_deferred("disabled", false)
		$PortalKeluar.visible = true # Munculkan visual portal/pintu (kalau ada gambarnya)

# Sinyal saat Player menyentuh portal
func _on_portal_keluar_body_entered(body):
	if body.name == "player":
		print("Level 3 Selesai! Melanjutkan ke Level 4...")
		get_tree().change_scene_to_file("res://level_4.tscn")
