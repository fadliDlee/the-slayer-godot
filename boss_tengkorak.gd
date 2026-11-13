extends CharacterBody2D

# --- STATUS BOS (FSM Variables) ---
var hp_musuh = 150 
var is_mati = false
var sedang_mengejar = false
var sedang_menyerang = false
var tipe_serangan = 0
var target_player = null
var sudah_kena_damage = false
const JARAK_BERHENTI = 80.0

# --- ATRIBUT FISIKA ---
const SPEED = 120.0 
var gravitasi = ProjectSettings.get_setting("physics/2d/default_gravity")

# --- REFERENSI UI DARAH ---
@onready var health_bar = $"../BossUI/HealthBarBos"

func _ready():
	# Inisialisasi bar darah agar sesuai dengan HP asli bos (150)
	if health_bar != null:
		health_bar.max_value = hp_musuh
		health_bar.value = hp_musuh

func _physics_process(delta):
	# 1. SELALU TERAPKAN GRAVITASI (Agar mayat bisa jatuh ke lantai)
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# 2. JIKA BOS MATI, BERHENTIKAN LOGIKA AI, TAPI TETAP JATUHKAN KE LANTAI
	if is_mati:
		velocity.x = 0
		move_and_slide() # Eksekusi dorongan gravitasi
		return
		
	# === REFACTORING: LOGIKA UTAMA AI BOS ===
	# Bos hanya bisa menentukan pergerakan & arah JIKA sedang TIDAK memutar animasi menyerang
	if not sedang_menyerang:
		
		# JIKA PLAYER TERDETEKSI (Ada di dalam AreaMata/Radar Bos)
		if target_player:
			# 1. HITUNG JARAK & ARAH HORIZONTAL
			var jarak_ke_player = abs(global_position.x - target_player.global_position.x)
			var direction = sign(target_player.global_position.x - global_position.x)
			
			# 2. KUNCI UTAMA: SELALU UPDATE ARAH HADAP BOS (FLIP)
			# Baris ini ditaruh di luar agar Bos tetap berbalik badan meskipun sedang diam
			if direction > 0:
				$Pivot.scale.x = 1
			elif direction < 0:
				$Pivot.scale.x = -1
			
			# 3. KONTROL PERGERAKAN BERDASARKAN JARAK
			if jarak_ke_player > JARAK_BERHENTI:
				# Jika Player jauh, kejar!
				velocity.x = direction * SPEED
				$Pivot/AnimatedSprite2D.position.y = -72 # Masukkan Angka Idle/Jalan kamu
				$Pivot/AnimatedSprite2D.play("lari")
			else:
				# Jika Player sudah dekat, berhenti di tempat (Siap menyerang)
				velocity.x = move_toward(velocity.x, 0, SPEED)
				$Pivot/AnimatedSprite2D.position.y = -72 # Masukkan Angka Idle/Jalan kamu
				$Pivot/AnimatedSprite2D.play("idle")
				
		# JIKA PLAYER TIDAK TERDETEKSI SAMA SEKALI
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			$Pivot/AnimatedSprite2D.position.y = -72 # Masukkan Angka Idle/Jalan kamu
			$Pivot/AnimatedSprite2D.play("idle")
			
	# Terapkan pergerakan fisik Godot untuk saat bos masih hidup
	move_and_slide()

# --- EVENT-DRIVEN: SENSOR MATA ---
func _on_area_mata_body_entered(body):
	if body.name == "player" and not is_mati:
		sedang_mengejar = true
		target_player = body
		print("LOG: Bos melihat Player! Mulai mengejar!")

func _on_area_mata_body_exited(body):
	if body.name == "player":
		sedang_mengejar = false
		target_player = null
		print("LOG: Player keluar dari jangkauan pandangan Bos.")

# --- EVENT-DRIVEN: SENSOR SERANG (AI Memilih 1 dari 3 Serangan) ---
func _on_area_serang_body_entered(body):
	if body.name == "player" and not is_mati and not sedang_menyerang and $CooldownTimer.is_stopped():
		sedang_menyerang = true
		sudah_kena_damage = false
		velocity.x = 0
		
		var acak = randi() % 3 
		
		if acak == 0:
			tipe_serangan = 1
			$Pivot/AreaSerang/CollisionMelee.disabled = false
			$Pivot/AnimatedSprite2D.position.y = -72 
			$Pivot/AnimatedSprite2D.play("serang_light")
		elif acak == 1:
			tipe_serangan = 2
			$Pivot/AreaSerang/CollisionMelee.disabled = false
			$Pivot/AnimatedSprite2D.position.y = -72 
			$Pivot/AnimatedSprite2D.play("serang_heavy")
		else:
			tipe_serangan = 3
			$Pivot/AnimatedSprite2D.position.y = -134 # Angka sakti serang_3 kamu
			$Pivot/AnimatedSprite2D.play("serang_3")
			
			# === AKTIFKAN JANGKAUAN JAUH & DOT TIMER ===
			$Pivot/AreaSerang/CollisionApi.disabled = false
			$TimerApi.start()
			print("LOG: Bos mengeluarkan Semburan Api Jarak Jauh!")

# --- EVENT-DRIVEN: PENANGANAN ANIMASI SELESAI ---
func _on_animated_sprite_2d_animation_finished():
	var nama_animasi = $Pivot/AnimatedSprite2D.animation
	
	if nama_animasi == "serang_light" or nama_animasi == "serang_heavy" or nama_animasi == "serang_3":
		sedang_menyerang = false 
		$CooldownTimer.start() 
		
		# === MATIKAN SEMUA HITBOX & TIMER API ===
		$Pivot/AreaSerang/CollisionApi.disabled = true
		$TimerApi.stop()
					
	elif nama_animasi == "mati":
		# Cari UI Level Complete di dalam Level 
		# (Pastikan scene level kamu memiliki CanvasLayer bernama "LevelCompleteScreen")
		var ui_tamat = get_tree().current_scene.get_node_or_null("LevelCompleteScreen")
		
		if ui_tamat:
			ui_tamat.show()
			get_tree().paused = true # Hentikan waktu permainan
		else:
			print("Error: UI LevelCompleteScreen tidak ditemukan di scene ini!")
			
		queue_free() # Hilangkan mayat bos

# --- FUNGSI MENERIMA DAMAGE ---
func kena_damage(damage_masuk):
	if is_mati:
		return 
		
	hp_musuh -= damage_masuk
	print("LOG: Bos terkena damage! Sisa HP Bos: ", hp_musuh)
	
	# === UPDATE DARAH DI UI SAAT TERKENA DAMAGE ===
	if health_bar != null:
		health_bar.value = hp_musuh
	
	if hp_musuh <= 0:
		is_mati = true
		sedang_mengejar = false
		sedang_menyerang = false
		velocity.x = 0
		
		# Hentikan semua serangan aktif (seperti api)
		$Pivot/AreaSerang/CollisionApi.set_deferred("disabled", true)
		$Pivot/AreaSerang/CollisionMelee.set_deferred("disabled", true)
		$TimerApi.stop()
		
		# Mainkan animasi mati
		$Pivot/AnimatedSprite2D.play("mati") 
		print("LOG: Bos Telah Gugur! Bersiap memunculkan layar tamat...")

func _on_cooldown_timer_timeout():
	var targets = $Pivot/AreaSerang.get_overlapping_bodies()
	for b in targets:
		if b.name == "player" and not is_mati:
			print("LOG: Cooldown habis, Player masih menempel! Serang lagi!")
			_on_area_serang_body_entered(b)

func _on_animated_sprite_2d_frame_changed():
	if sedang_menyerang and not sudah_kena_damage and (tipe_serangan == 1 or tipe_serangan == 2):
		var frame_sekarang = $Pivot/AnimatedSprite2D.frame
		var frame_tebasan = 3 
		
		if frame_sekarang == frame_tebasan:
			var targets = $Pivot/AreaSerang.get_overlapping_bodies()
			for b in targets:
				if b.name == "player" and b.has_method("kena_damage"):
					if tipe_serangan == 1:
						b.kena_damage(10)
					elif tipe_serangan == 2:
						b.kena_damage(25)
			sudah_kena_damage = true
			
# --- EVENT-DRIVEN: TICK DAMAGE API ---
func _on_timer_api_timeout():
	if is_mati:
		$TimerApi.stop()
		return
		
	var targets = $Pivot/AreaSerang.get_overlapping_bodies()
	for b in targets:
		if b.name == "player" and b.has_method("kena_damage"):
			b.kena_damage(6)
			print("LOG: Player terpanggang api jarak jauh Bos! (-6 HP)")
