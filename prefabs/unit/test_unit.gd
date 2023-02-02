extends Unit

@onready var sprite = $Sprite2D

func _ready():
	
	unit_tex = load("res://textures/units/testunit.png")
	
	sprite.texture = unit_tex


func on_move():
	var world = get_tree().get_nodes_in_group("World")[0] 
	
	position = world.map.map_to_local(grid_pos)
