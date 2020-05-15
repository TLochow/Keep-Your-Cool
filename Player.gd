extends KinematicBody2D

var Motion = Vector2(0.0, 0.0)

var Coolness = 100.0

var GameOver = false

func ApplySeason(season, delta):
	if season == "Winter":
		Coolness = min(Coolness + (delta * 7.5), 100.0)
	elif season == "Spring":
		Coolness = max(Coolness - (delta * 7.5), 0.0)
	elif season == "Summer":
		Coolness = max(Coolness - (delta * 10.0), 0.0)
	elif season == "Fall":
		Coolness = max(Coolness - (delta * 5.0), 0.0)
	
	$Coolness.value = Coolness

func _physics_process(delta):
	Motion.y += 10.0
	
	var xMove = 0.0
	if not GameOver:
		if Input.is_action_pressed("ui_left"):
			xMove += -100.0
		if Input.is_action_pressed("ui_right"):
			xMove += 100.0
		if Input.is_action_just_pressed("ui_up"):
			if is_on_floor():
				Motion.y = -300.0
				$JumpSound.play()
	
	Motion.x = xMove
	var potentialParticles = Motion.y >= 100.0
	Motion = move_and_slide(Motion, Vector2(0.0, -1.0))
	if potentialParticles and Motion.y <= 0.0:
		$FallParticlesLeft.emitting = true
		$FallParticlesRight.emitting = true
	var moving = false
	if Motion.x < 0.0:
		$Sprite.flip_h = true
		$WalkingParticles.process_material.set("direction", Vector3(1.0, -0.5, 0.0))
		moving = true
	elif Motion.x > 0.0:
		$Sprite.flip_h = false
		$WalkingParticles.process_material.set("direction", Vector3(-1.0, -0.5, 0.0))
		moving = true
	
	if moving:
		SwitchAnimation($AnimationPlayer, "Walk")
		$WalkingParticles.emitting = true
	else:
		SwitchAnimation($AnimationPlayer, "Stand")
		$WalkingParticles.emitting = false

func SwitchAnimation(animationPlayer, animation):
	if animationPlayer.current_animation != animation:
		animationPlayer.play(animation)
