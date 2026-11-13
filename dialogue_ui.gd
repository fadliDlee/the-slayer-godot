extends CanvasLayer

@onready var text_label = $Panel/TextLabel
var dialog_texts: Array[String] = []
var current_index: int = 0
var is_active: bool = false

func _ready():
	hide() # Sembunyikan UI saat game mulai

func start_dialog(texts: Array[String]):
	dialog_texts = texts
	current_index = 0
	is_active = true
	show()
	tampilkan_teks()

func tampilkan_teks():
	if current_index < dialog_texts.size():
		# Tampilkan teks sesuai urutan
		text_label.text = dialog_texts[current_index]
	else:
		# Jika teks habis, tutup dialog
		selesai_dialog()

func _input(event):
	# Jika dialog aktif dan pemain menekan Spasi/Enter
	if is_active and event.is_action_pressed("ui_accept"):
		current_index += 1
		tampilkan_teks()

func selesai_dialog():
	is_active = false
	hide()
