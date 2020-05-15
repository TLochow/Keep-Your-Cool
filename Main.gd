extends Node2D

var GameOver = false
var Won = false

var Season = "Winter"

var Switching = false

var GotSpringPotion = false
var GotSummerPotion = false
var GotFallPotion = false
var GotWinterPotion = false

var StartMilliseconds
var Milliseconds
var Seconds
var Minutes

func _ready():
	StartMilliseconds = OS.get_ticks_msec()

func SetElapsedTime():
	var elapsed = OS.get_ticks_msec() - StartMilliseconds
	Milliseconds = elapsed % 1000
	elapsed -= Milliseconds
	elapsed /= 1000
	Seconds = elapsed % 60
	elapsed -= Seconds
	elapsed /= 60
	Minutes = elapsed
	$CanvasLayer/UI/Time.text = "Time: " + str(Minutes) + " Minutes " + str(Seconds) + " Seconds " + str(Milliseconds) + " Milliseconds"

func _process(delta):
	if not GameOver:
		SetElapsedTime()
		$Player.ApplySeason(Season, delta)
		
		if $Player.Coolness <= 0.0:
			GameOver = true
			$Player.GameOver = true
			$CanvasLayer/Loose.visible = true

func _input(event):
	if event.is_action_pressed("ui_accept"):
		if GameOver:
			get_tree().change_scene("res://Main.tscn")
		elif not Switching:
			$SeasonSound.play()
			Switching = true
			$WhiteTween.interpolate_property($CanvasLayer/White, "color", Color(1.0, 1.0, 1.0, 0.0), Color(1.0, 1.0, 1.0, 1.0), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$WhiteTween.start()
	elif event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	elif event.is_action_pressed("ui_restart"):
		get_tree().change_scene("res://Main.tscn")

func ChangeSeason():
	if Season == "Winter":
		Season = "Spring"
		$Player.collision_layer = 1
		$Player.collision_mask = 1
	elif Season == "Spring":
		Season = "Summer"
		$Player.collision_layer = 2
		$Player.collision_mask = 2
	elif Season == "Summer":
		Season = "Fall"
		$Player.collision_layer = 4
		$Player.collision_mask = 4
	elif Season == "Fall":
		Season = "Winter"
		$Player.collision_layer = 8
		$Player.collision_mask = 8
	
	$Seasons/Spring.visible = Season == "Spring"
	$Seasons/Summer.visible = Season == "Summer"
	$Seasons/Fall.visible = Season == "Fall"
	$Seasons/Winter.visible = Season == "Winter"

func _on_WhiteTween_tween_all_completed():
	if Switching:
		Switching = false
		ChangeSeason()
		$WhiteTween.interpolate_property($CanvasLayer/White, "color", Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$WhiteTween.start()

func CheckForWin():
	$PickupSound.play()
	if GotFallPotion and GotSpringPotion and GotSummerPotion and GotWinterPotion:
		SetElapsedTime()
		GameOver = true
		Won = true
		$Player.GameOver = true
		$CanvasLayer/Win.visible = true
		$CanvasLayer/Win/Time.text = """You beat the game in
		""" + str(Minutes) + """ Minutes,
		""" + str(Seconds) + """ Seconds and
		""" + str(Milliseconds) + " Milliseconds!"

func _on_WinterPotion_body_entered(body):
	GotWinterPotion = true
	CheckForWin()
	$Seasons/Winter/WinterPotion.queue_free()

func _on_FallPotion_body_entered(body):
	GotFallPotion = true
	CheckForWin()
	$Seasons/Fall/FallPotion.queue_free()

func _on_SummerPotion_body_entered(body):
	GotSummerPotion = true
	CheckForWin()
	$Seasons/Summer/SummerPotion.queue_free()

func _on_SpringPotion_body_entered(body):
	GotSpringPotion = true
	CheckForWin()
	$Seasons/Spring/SpringPotion.queue_free()
