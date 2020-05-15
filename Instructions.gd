extends Control

func _input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene("res://Main.tscn")
	elif event.is_action_pressed("ui_cancel"):
		get_tree().quit()
