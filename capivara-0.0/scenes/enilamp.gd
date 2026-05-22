extends CharacterBody2D

var move = 200
var grav = 50
var tou_wall = 10
var plesswall = false
var hp = 30
@onready var hurtbox = $Hurtbox
var took_damage = false
var player = 0
@onready var inimigo = $AnimatedSprite2D
func _process(_delta: float) -> void:
	
	walk()
	
	grav_eni()
	
	contable()
	
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
	else:
		tou_wall = 0

func _on_hurtbox_area_entered(area: Area2D) -> void:
	print(area.name)
	print(area.get_groups())
	if area == hurtbox:
		return
	if area.is_in_group("PORRADA_DO_PLAYER"):
		hp -= 1
		
		took_damage = true
		player = get_tree().get_first_node_in_group("player")
		
		if player.global_position.x < global_position.x:
			velocity.x = 700
		else:
			velocity.x = -700
	
		velocity.y = -200
		
		for i in range(4):
			inimigo.modulate = Color(255.014, 255.014, 255.014, 1.0)
			await get_tree().create_timer(0.05).timeout
			inimigo.modulate = Color(1,1,1,1)
			await get_tree().create_timer(0.05).timeout
		
		await get_tree().create_timer(0.3).timeout
		
		took_damage = false
		
		if hp <= 0:
			queue_free()
		
		


func _on_hurtbox_area_entered_ASS_POWER(area: Area2D) -> void:
	print(area.name)
	if area == hurtbox:
		return
	if area.is_in_group("ASS_POWER"):
		hp -= 5
		print("ass_power acertou")
		took_damage = true
		player = get_tree().get_first_node_in_group("player")
		
		if player.global_position.x < global_position.x:
			velocity.x = 1000
		else:
			velocity.x = -1000

		velocity.y = -600
		
		for i in range(4):
			inimigo.modulate = Color(255.014, 255.014, 255.014, 1.0)
			await get_tree().create_timer(0.05).timeout
			inimigo.modulate = Color(1,1,1,1)
			await get_tree().create_timer(0.05).timeout
		
		await get_tree().create_timer(0.9).timeout
		
		took_damage = false
		
		if hp <= 0:
			queue_free()
