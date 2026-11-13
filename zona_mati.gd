extends Area2D

func _on_body_entered(body):
	if body.name == "player":
		print("The Slayer jatuh ke jurang!")
		get_tree().reload_current_scene()
