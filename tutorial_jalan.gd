extends Area2D

@export var teks_panduan: RichTextLabel

func _on_body_entered(body):
	# Memastikan bahwa yang menginjak saklar adalah The Slayer
	if body.name == "player" or body.has_method("kena_damage"):
		if teks_panduan != null:
			teks_panduan.show()

func _on_body_exited(body):
	# Menyembunyikan teks saat The Slayer pergi
	if body.name == "player" or body.has_method("kena_damage"):
		if teks_panduan != null:
			teks_panduan.hide()
