extends Control

# Ubah baris ini agar mencocokkan nama node di panel Scene sebelah kiri
@onready var text_label = $RichTextLabel  
@onready var tombol_lanjut = $Button

var daftar_cerita: Array[String] = [
	"Di sebuah dunia yang gelap dan sunyi...",
	"Seorang pahlawan tersesat di dalam gua bawah tanah yang penuh dengan mara bahaya.",
	"Tanpa senjata lengkap dan ingatan yang utuh, ia harus berjuang mencari jalan keluar.",
	"Perjalanan dimulai..."
]

var indeks_cerita: int = 0

func _ready():
	tombol_lanjut.pressed.connect(_on_tombol_lanjut_pressed)
	tampilkan_teks_berikutnya()

func tampilkan_teks_berikutnya():
	if indeks_cerita < daftar_cerita.size():
		text_label.text = daftar_cerita[indeks_cerita]
	else:
		pindah_ke_gameplay()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		indeks_cerita += 1
		tampilkan_teks_berikutnya()

func _on_tombol_lanjut_pressed():
	indeks_cerita += 1
	tampilkan_teks_berikutnya()

func pindah_ke_gameplay():
	get_tree().change_scene_to_file("res://level_1.tscn")
