extends CharacterBody2D

# ==========================================
# 1. DEKLARASI VARIABEL & REFERENSI UI
# ==========================================
@export var health_bar: TextureProgressBar

@onready var game_over_screen = $GameOverScreen

# Variabel Status Vitalitas
var hp_maksimal = 100
var hp_sekarang = 100
var can_take_damage = true 

# Variabel State Machine
var is_mati = false 
var is_attacking = false
var is_dashing = false
var can_dash = true
var combo_count = 0 

# Variabel Konstanta Fisika
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const DASH_SPEED = 800.0 

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


# ==========================================
# 2. INISIALISASI AWAL
# ==========================================
func _ready():
	if health_bar != null:
		health_bar.max_value = hp_maksimal
		health_bar.value = hp_sekarang
		update_ui() 
	else:
		print("PERINGATAN: Health Bar belum di-assign di Inspector!")


# ==========================================
# 3. PROSES FISIKA UTAMA
# ==========================================
func _physics_process(delta):
	if is_mati:
		return

	# Penerapan Gravitasi
	if not is_on_floor() and not is_dashing:
		velocity.y += gravity * delta

	# Pengaturan State Prioritas
	if is_dashing:
		velocity.y = 0 
	elif is_attacking:
		if is_on_floor():
			velocity.x = 0 
	
	# Logika Input Normal
	else:
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		if Input.is_action_just_pressed("attack"):
			start_combo()
			
		if Input.is_action_just_pressed("dash") and can_dash:
			start_dash()
		
		# Logika Berjalan Kiri-Kanan (Hanya aktif jika tidak dash dan tidak menyerang)
		if not is_dashing and not is_attacking:
			var direction = Input.get_axis("ui_left", "ui_right")
			if direction:
				velocity.x = direction * SPEED
				
				# Membalikkan visual gambar
				$AnimatedSprite2D.flip_h = (direction < 0)
				
				# --- FIX BUG HITBOX ---
				# Membalikkan arah kotak tebasan pedang agar sinkron dengan gambar
				if direction < 0:
					$SwordHitbox.scale.x = -1 # Menghadap Kiri
				else:
					$SwordHitbox.scale.x = 1  # Menghadap Kanan
					
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)

	# Update Animasi & Pergerakan
	play_basic_animations(Input.get_axis("ui_left", "ui_right"))
	move_and_slide()
	
	# --- DETEKSI KARAKTER JATUH KE JURANG ---
	# Angka 1000 adalah batas kedalaman layar bawah.
	# Jika karakter jatuh melewati angka ini, fungsi mati() akan dipanggil.
	if global_position.y > 400:
		mati()
	
	# Debugging Tool (Tombol T)
	if Input.is_physical_key_pressed(KEY_T):
		if Engine.get_process_frames() % 10 == 0: 
			kena_damage(5)


# ==========================================
# 4. FUNGSI MEKANIK (DASH & COMBO)
# ==========================================
func start_dash():
	is_dashing = true
	can_dash = false
	$AnimatedSprite2D.play("dash")
	
	var dash_direction = -1 if $AnimatedSprite2D.flip_h else 1
	velocity.x = dash_direction * DASH_SPEED
	
	$DashTimer.start()
	$DashCooldown.start()

func start_combo():
	is_attacking = true
	velocity.x = 0 
	
	combo_count += 1
	if combo_count > 3: combo_count = 1
	
	$AnimatedSprite2D.play("attack" + str(combo_count))
	$ComboTimer.start()
	
	$SwordHitbox/CollisionShape2D.set_deferred("disabled", false)
	await get_tree().create_timer(0.6).timeout
	$SwordHitbox/CollisionShape2D.set_deferred("disabled", true)
	is_attacking = false


# ==========================================
# 5. SISTEM ANIMASI
# ==========================================
func play_basic_animations(direction):
	if is_attacking or is_dashing: return 

	if is_on_floor():
		if direction == 0: $AnimatedSprite2D.play("idle")
		else: $AnimatedSprite2D.play("run")
	else:
		if velocity.y < 0: $AnimatedSprite2D.play("jump")
		else: $AnimatedSprite2D.play("fall")


# ==========================================
# 6. CALLBACK SINYAL
# ==========================================
func _on_animated_sprite_2d_animation_finished():
	if "attack" in $AnimatedSprite2D.animation:
		is_attacking = false
		if combo_count == 3: combo_count = 0

func _on_combo_timer_timeout(): combo_count = 0
func _on_dash_timer_timeout(): is_dashing = false
func _on_dash_cooldown_timeout(): can_dash = true

func _on_zona_mati_body_entered(body):
	if body == self: mati()


# ==========================================
# 7. SISTEM VITALITAS & UI
# ==========================================
func kena_damage(jumlah_luka):
	if is_mati or not can_take_damage:
		return
		
	hp_sekarang -= jumlah_luka
	update_ui()
	
	can_take_damage = false
	$AnimatedSprite2D.modulate = Color(1, 0, 0) # Flash Merah
	
	await get_tree().create_timer(0.5).timeout # Kebal 0.5 detik
	
	can_take_damage = true
	$AnimatedSprite2D.modulate = Color(1, 1, 1) # Kembali Normal
	
	if hp_sekarang <= 0:
		mati()

func update_ui():
	if health_bar != null:
		health_bar.value = hp_sekarang

func mati():
	if is_mati: return 
	is_mati = true
	hp_sekarang = 0
	update_ui()
	
	velocity = Vector2.ZERO # Hentikan gerakan
	print("THE SLAYER GUGUR!")
	
	# 1. Mainkan animasi mati
	# (Pastikan ejaannya sama persis dengan yang ada di SpriteFrames)
	$AnimatedSprite2D.play("mati") 
	
	# 2. Tunggu sampai animasi mati selesai diputar dengan sempurna
	await $AnimatedSprite2D.animation_finished
	
	# 3. Jeda ekstra sedikit biar layar tidak langsung kedip tertutup UI
	await get_tree().create_timer(0.5).timeout
	
	# 4. Munculkan Layar Game Over dan hentikan waktu permainan
	if game_over_screen:
		game_over_screen.show()
		get_tree().paused = true
	else:
		print("Error: Node GameOverScreen tidak ditemukan!")


func _on_sword_hitbox_body_entered(body):
	# 1. Cegah pedang melukai badan Player sendiri
	if body == self:
		return
		
	# 2. Jika yang terkena tebasan punya fungsi "kena_damage" (Musuh)
	if body.has_method("kena_damage"):
		# Berikan damage ke musuh (Misal: 10 damage per tebasan)
		body.kena_damage(10)
