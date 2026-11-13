extends CharacterBody2D

var kecepatan = 80.0
var gravitasi = ProjectSettings.get_setting("physics/2d/default_gravity")

var sedang_mengejar = false
var sedang_menyerang = false
var target_player = null

# Ambil referensi ke node Pivot
@onready var pivot = $Pivot

func _physics_process(delta):
	# 1. Gravitasi
	if not is_on_floor():
		velocity.y += gravitasi * delta

	# 2. LOGIKA ARAH (Memutar seluruh Pivot)
	if target_player != null:
		var arah_x = sign(target_player.global_position.x - global_position.x)
		
		if arah_x > 0:
			# Menghadap Kanan: Scale X normal
			pivot.scale.x = 1
		elif arah_x < 0:
			# Menghadap Kiri: Scale X dibalik (Otomatis membalik gambar & semua area sensor)
			pivot.scale.x = -1

	# 3. Logika State Machine
	if sedang_menyerang:
		velocity.x = 0
		$Pivot/AnimatedSprite2D.play("serang")
	elif sedang_mengejar and target_player != null:
		var jarak_x = target_player.global_position.x - global_position.x
		if abs(jarak_x) > 20:
			velocity.x = sign(jarak_x) * kecepatan
			$Pivot/AnimatedSprite2D.play("lari")
		else:
			velocity.x = 0
			$Pivot/AnimatedSprite2D.play("idle")
	else:
		velocity.x = move_toward(velocity.x, 0, kecepatan)
		$Pivot/AnimatedSprite2D.play("idle")

	move_and_slide()

# --- BAGIAN SINYAL (Update path ke $Pivot/...) ---

func _on_area_mata_body_entered(body):
	if body.name == "player":
		target_player = body
		sedang_mengejar = true

func _on_area_mata_body_exited(body):
	if body.name == "player":
		target_player = null
		sedang_mengejar = false
		sedang_menyerang = false 

func _on_area_serang_body_entered(body):
	if body.name == "player":
		sedang_menyerang = true
		if body.has_method("ambil_damage"):
			body.ambil_damage(1)

func _on_animated_sprite_2d_animation_finished():
	if $Pivot/AnimatedSprite2D.animation == "serang":
		sedang_menyerang = false 
		
		# Cek ulang jangkauan menggunakan area di dalam pivot
		var targets = $Pivot/AreaSerang.get_overlapping_bodies()
		for b in targets:
			if b.name == "player":
				sedang_menyerang = true
