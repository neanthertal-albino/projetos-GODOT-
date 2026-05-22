extends CharacterBody2D

var move = 200
var grav = 50
var tou_wall = 10
var plesswall = false
var hp = 30
@onready var hurtbox = $Hurtbox
var took_damage = false

func _process(_delta: float) -> void:
	
	walk()
	
	grav_eni()
	
	contable()
	
	_on_hurtbox_area_entered(hurtbox)
	
	move_and_slide()

func walk():
	if took_damage:
		return
		
	if plesswall == false:
		velocity.x = move_toward(velocity.x, move, 10)
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.play("idle")
	else:
		velocity.x = move_toward(velocity.x, -move, 10)
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.play("idle")
		
		
		

func grav_eni():
	if !is_on_floor():
		velocity.y += 10
	
func contable():
	if took_damage == false:
		if plesswall == false:
			tou_wall += 0.1
		if tou_wall >= 20:
			plesswall = true
		if plesswall == true:
			tou_wall -= 0.1
		if tou_wall <= 0:
			plesswall = false
		

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area == hurtbox:
		return
	if area.is_in_group("PORRADA_DO_PLAYER"):
		hp -= 1
		
		took_damage = true
		
		velocity.x = 500
		velocity.y = -200
		await get_tree().create_timer(0.3).timeout
		
		took_damage = false
		
		if hp <= 0:
			queue_free()
		
		
