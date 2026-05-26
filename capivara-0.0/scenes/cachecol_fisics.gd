extends Node2D

@onready var line = $Line2D
@onready var sprite = get_parent().get_node("AnimatedSprite2D")

var points = []

const SEGMENTS = 6

func _ready():

	line.width = 3

	for i in range(SEGMENTS):
		points.append(Vector2.ZERO)

func _physics_process(_delta):

	# começo do cachecol
	if sprite.flip_h:
		points[0] = Vector2(4, -2)
	else:
		points[0] = Vector2(-4, -2)

	# física fake
	for i in range(1, SEGMENTS):

		var target = points[i - 1]
		var current = points[i]

		# suavização
		current = current.lerp(target, 0.1)

		# distância fixa
		var dir = current - target

		var max_distance = 1

		if dir.length() > max_distance:
			dir = dir.normalized()
			current = target + dir * max_distance

		points[i] = current

		points[i].y += 1

		# influência da velocidade
		var vel = get_parent().velocity

		points[i].x -= vel.x * (i * 0.001)

		points[i].y -= vel.y * (i * 0.001)

	line.clear_points()

	for p in points:
		line.add_point(p)
