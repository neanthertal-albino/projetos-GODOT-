extends Node2D

@export var scarf_length := 6
@export var segment_size := 6.0
@export var follow_speed := 30.0
@export var gravity := Vector2(0, 200)

@onready var player = get_parent()
@onready var line: Line2D = $Line2D

var points: Array[Vector2] = []

func _ready():
	for i in scarf_length:
		points.append(global_position)

func _physics_process(delta):

	# Primeiro ponto preso ao pescoço
	points[0] = global_position

	# Física básica
	for i in range(1, points.size()):

		var target = points[i - 1]

		# Gravidade
		points[i] += gravity * delta

		# Seguir o ponto anterior
		points[i] = points[i].lerp(
			target,
			min(follow_speed * delta, 1.0)
		)

		# Distância fixa
		var dir = (points[i] - target).normalized()
		points[i] = target + dir * segment_size

		# Vento baseado na velocidade
		if player.has_method("get_velocity") or "velocity" in player:
			var wind = clamp(abs(player.velocity.x) / 1300.0, 0.0, 1.0)

			points[i].x -= sign(player.velocity.x) * wind * i * 2.0

	# Correção extra para evitar esticamento
	for _pass in range(4):

		points[0] = global_position

		for i in range(1, points.size()):

			var target = points[i - 1]

			var dir = (points[i] - target).normalized()
			points[i] = target + dir * segment_size

	# Atualiza o Line2D
	line.clear_points()

	for p in points:
		line.add_point(to_local(p))
