extends Camera2D

@onready var topLeft = $"../Limits/TopLeft"
@onready var botRight = $"../Limits/BottomRight"

# Called when the node enters the scene tree for the first time.
func _ready():
	#set_cam_limits(topLeft.position, botRight.position)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_cam_limits(topL : Vector2, botR : Vector2) -> void:
	limit_top = topL.y
	limit_left = topL.x
	limit_bottom = botR.y
	limit_bottom = botR.x
