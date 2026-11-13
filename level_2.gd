extends Node2D

@onready var portal = $Portal # Pastikan nama nodenya sesuai dengan nama portalmu di scene
var portal_sudah_muncul = false

func _process(_delta):
	# Jika portal sudah muncul, hentikan pengecekan agar hemat performa RAM
	if portal_sudah_muncul:
		return
		
	# Hitung berapa jumlah musuh yang masih hidup di dalam grup "musuh"
	var jumlah_musuh = get_tree().get_nodes_in_group("musuh").size()
	
	# JIKA SEMUA MUSUH SUDAH MATI (Jumlahnya mencapai 0)
	if jumlah_musuh == 0:
		munculkan_portal()

func munculkan_portal():
	portal_sudah_muncul = true
	print("LOG: Semua musuh tumbang! Portal Level 3 Terbuka!")
	
	# Munculkan visual portalnya
	portal.visible = true
	
	# Aktifkan kembali sensor tabrakan portal menggunakan set_deferred agar aman dari crash
	portal.get_node("CollisionShape2D").set_deferred("disabled", false)
