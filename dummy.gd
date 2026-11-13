extends StaticBody2D

# WAJIB ADA: Agar Level 1 bisa tahu saat dummy hancur
signal mati 

var health = 3
var is_dead = false # Flag agar tidak dipukul saat sudah mati

func _ready():
	$AnimatedSprite2D.play("idle")
	is_dead = false # Reset status saat game mulai

# Fungsi pendeteksi serangan
func _on_hurtbox_area_entered(area):
	# Jika dummy sudah mati atau yang masuk bukan pedang, abaikan
	if is_dead: 
		return
		
	if area.name == "SwordHitbox":
		take_damage()

func take_damage():
	health -= 1
	print("Dummy Terluka! Sisa HP: ", health)
	
	# Mainkan animasi hit
	$AnimatedSprite2D.play("hit")
	
	if health <= 0:
		hancur()

func hancur():
	is_dead = true
	print("Dummy Hancur! Mengirim laporan...")
	
	# Beritahu Level 1
	mati.emit()
	
	# Langsung hapus (untuk tes awal agar tidak macet di animasi)
	queue_free()

# Kembalikan ke idle kalau animasi hit selesai
func _on_animated_sprite_2d_animation_finished():
	if not is_dead and $AnimatedSprite2D.animation == "hit":
		$AnimatedSprite2D.play("idle")
