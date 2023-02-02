extends Node

var world


# - pos, unit node
var spawned_units := []


var testunit_prefab = preload("res://prefabs/unit/test_unit.tscn")



# Called when the node enters the scene tree for the first time.
func initialize():
	
	world = get_parent()
	
	# -- spawn test unit
	var u = testunit_prefab.instantiate()
	add_child(u)
	
	# get random map pos
	var pos := Vector2i(randi_range(0, world.map_size.x), randi_range(0, world.map_size.y))
	u.grid_pos = pos
	u.on_move()
	u.unit_name = str(randi_range(0, 100000000))
	
	spawned_units.append(u)
	print(spawned_units)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
