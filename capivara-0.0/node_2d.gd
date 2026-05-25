extends Node2D

@onready var line = $Line2D

func _ready():

	line.width = 20
	line.default_color = Color.RED

	line.add_point(Vector2(0,0))
	line.add_point(Vector2(300,0))
