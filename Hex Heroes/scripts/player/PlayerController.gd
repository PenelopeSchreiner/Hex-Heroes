extends Node2D

@onready var cam = $Camera2D

var cam_speed := 350.0

var zoom_speed := 50.0
var zoom_level := Vector2(1.0, 1.0)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_action_pressed("left"):
		cam.position.x += -1 * cam_speed * zoom_level.x * delta
	if Input.is_action_pressed("right"):
		cam.position.x += 1 * cam_speed * zoom_level.x * delta
	if Input.is_action_pressed("up"):
		cam.position.y += -1 * cam_speed * zoom_level.y * delta
	if Input.is_action_pressed("down"):
		cam.position.y += 1 * cam_speed * zoom_level.y * delta
	pass
