extends CharacterBody2D

var move = 200
var grav = 50
var tou_wall = 10
var plesswall = false

func _process(_delta: float) -> void:
	
	walk()
	
	grav_eni()
	
	contable()
	
	move_and_slide()

func walk():
	if plesswall == false:
		velocity.x = move
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.play("idle")
	else:
		velocity.x = -move
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play("idle")
		

func grav_eni():
	if !is_on_floor():
		velocity.y += grav
	
func contable():
	if plesswall == false:
		tou_wall += 0.1
	if tou_wall >= 20:
		plesswall = true
	if plesswall == true:
		tou_wall -= 0.1
	if tou_wall <= 0:
		plesswall = false

func detected_rays():
	print("i dont know what to do now")
