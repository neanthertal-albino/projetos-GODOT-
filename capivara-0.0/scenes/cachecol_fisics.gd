extends Node2D

@onready var line = $Line2D

var points = []

const SEGMENTS = 4

func _ready():

	line.width = 5

	for i in range(SEGMENTS):
		points.append(Vector2.ZERO)

func _physics_process(_delta):

	# começo do cachecol
	points[0] = Vector2(0, -2)
	
	# física fake
	for i in range(1, SEGMENTS):
		
		var target = points[i - 1]
		var current = points[i]
		
		# suavização
		current = current.lerp(target, 0.1)
		
		# distância fixa
		var dir = current - target
		
		var max_distance = 5
		
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
