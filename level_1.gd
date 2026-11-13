extends Node2D

@export var gerbang_node: Area2D
var jumlah_mati = 0

func _ready():
	# Cara manual tapi paling aman dari error (Logika aslimu tetap dipertahankan)
	if has_node("Dummy"):
		$Dummy.mati.connect(_on_musuh_tumbang)
	if has_node("Dummy2"):
		$Dummy2.mati.connect(_on_musuh_tumbang)

func _on_musuh_tumbang():
	jumlah_mati += 1
	print("LOG: Total mati = ", jumlah_mati)
	
	if jumlah_mati >= 2:
		if gerbang_node:
			print("LOG: Semua musuh mati! Gerbang Level 1 Terbuka!")
			# 1. Munculkan visual portalnya
			gerbang_node.visible = true
			
			# 2. Nyalakan kotak fisikanya agar bisa ditabrak Player
			gerbang_node.get_node("CollisionShape2D").set_deferred("disabled", false)
