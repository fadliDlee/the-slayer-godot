extends CharacterBody2D

var kecepatan = 80.0
var gravitasi = ProjectSettings.get_setting("physics/2d/default_gravity")

var sedang_mengejar = false
var sedang_menyerang = false
var target_player = null

var hp_musuh = 30 # Nyawa musuh (sesuaikan)
var is_mati = false # Status kematian

# Ambil referensi ke node Pivot (Pastikan namanya 'Pivot' di Scene Tree)
@onready var pivot = $Pivot

func _physics_process(delta):
	# Jika musuh mati, dia hanya bisa jatuh ke tanah, logika lain dibatalkan
	if is_mati:
		if not is_on_floor():
			velocity.y += gravitasi * delta
		move_and_slide()
		return

	# 2. LOGIKA ARAH (Memutar seluruh isi Pivot)
	if target_player != null:
		var arah_x = sign(target_player.global_position.x - global_position.x)
		
		if arah_x > 0:
			# Menghadap Kanan (Asumsi aset awalmu menghadap Kanan)
			pivot.scale.x = 1
		elif arah_x < 0:
			# Menghadap Kiri (Membalik semua isi pivot sekaligus)
			pivot.scale.x = -1

	# 3. State Machine
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

# --- BAGIAN SINYAL (Pastikan jalurnya tepat ke dalam Pivot!) ---

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
		# Hanya pasang pose menyerang, JANGAN berikan damage di sini
		sedang_menyerang = true

func _on_animated_sprite_2d_animation_finished():
	# Cek apakah nama animasinya benar "serang"
	# (Sesuaikan path-nya, pakai $Pivot/... jika animasi ada di dalam Pivot)
	if $Pivot/AnimatedSprite2D.animation == "serang":
		
		# Reset state serang
		sedang_menyerang = false 
		
		# Pengecekan Area: Siapa saja yang sedang berdiri di dalam AreaSerang saat pedang ditebaskan?
		var targets = $Pivot/AreaSerang.get_overlapping_bodies()
		
		for b in targets:
			if b.name == "player":
				# Jika player masih ada di depan musuh, serang lagi dan BERIKAN DAMAGE
				sedang_menyerang = true 
				if b.has_method("kena_damage"):
					b.kena_damage(10)
					print("LOG: Serangan Musuh Mendarat!")
					

func kena_damage(jumlah_luka):
	if is_mati: return
	
	hp_musuh -= jumlah_luka
	print("Tengkorak kena tebas! Sisa HP: ", hp_musuh)
	
	# Efek merah sebentar saat kena tebas
	$Pivot/AnimatedSprite2D.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	if not is_mati: # Cek lagi agar warna tidak error kalau dia mati
		$Pivot/AnimatedSprite2D.modulate = Color(1, 1, 1)
	
	if hp_musuh <= 0:
		mati()

func mati():
	# Cegah fungsi ini tereksekusi berkali-kali jika terkena tebasan beruntun
	if is_mati: return 
	
	is_mati = true
	sedang_menyerang = false
	sedang_mengejar = false
	velocity = Vector2.ZERO # Hentikan semua gerakan seketika
	
	print("Musuh Tumbang!")
	
	# HAPUS BARIS INI: $CollisionShape2D.set_deferred("disabled", true)
	
	# MATIKAN SENSORNYA SAJA (Pastikan path-nya sesuai dengan scene-mu)
	# Ini membuat musuh mati tidak akan menyerang/melihat player lagi
	if has_node("Pivot/AreaSerang/CollisionShape2D"):
		$Pivot/AreaSerang/CollisionShape2D.set_deferred("disabled", true)
	if has_node("Pivot/AreaMata/CollisionShape2D"):
		$Pivot/AreaMata/CollisionShape2D.set_deferred("disabled", true)
	
	# Mainkan animasi
	$Pivot/AnimatedSprite2D.play("mati")
	
	# Tunggu sampai frame terakhir animasi selesai
	await $Pivot/AnimatedSprite2D.animation_finished
	
	# Baru setelah animasinya selesai, kita hapus musuhnya dari dunia
	queue_free()
