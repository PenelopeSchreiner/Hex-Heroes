extends CharacterBody2D

@onready var cam = $Camera2D

var cam_speed := 350.0

var zoom_factor := 0.1
var zoom_level := 1.0
var zoom_min := 0.8
var zoom_max := 2.5

var inverse_zoom : float = 1.0

var dir : Vector2

# -- misc
var selector_prefab = preload("res://prefabs/player/selector.tscn")
var selector


var world


# -- units
var targeted_unit : Node


# Called when the node enters the scene tree for the first time.
func initialize():
	
	world = get_tree().get_nodes_in_group("World")[0]
	
	# - selector
	selector = selector_prefab.instantiate()
	world.get_player_holder().add_child(selector)
	selector.position = world.get_map().map_to_local(Vector2i(0, 0))
	selector.hide()
	
	# set camera limits
	#var map_bot_right : Vector2i = world.map.get_used_rect().position + world.map.get_used_rect().size 
	#cam.set_cam_limits(world.position, map_bot_right * world.map.tile_set.tile_size)
	#print(world.position)
	#print(map_bot_right)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# camera movement
	
	if Input.is_action_pressed("left"):
		#if cam.position.x > -world.world_size.x * 0.25:
		dir.x += -1
	if Input.is_action_pressed("right"):
		#if cam.position.x + get_viewport_rect().size.x < world.world_size.x * 1.2:
		dir.x += 1
	if Input.is_action_pressed("up"):
		#if cam.position.y > - world.world_size.y * 0.25:
		dir.y += -1
	if Input.is_action_pressed("down"):
		#if cam.position.y + get_viewport_rect().size.y < world.world_size.y * 1.2:
		dir.y += 1
	
	if Input.is_action_just_released("left"):
		dir.x = 0
	if Input.is_action_just_released("right"):
		dir.x = 0
	if Input.is_action_just_released("up"):
		dir.y = 0
	if Input.is_action_just_released("down"):
		dir.y = 0


func _physics_process(delta):
	velocity = dir.normalized() * cam_speed * inverse_zoom
	
	move_and_slide()


func _unhandled_input(event):
	
	# - camera zooming
	if event.is_action_pressed("zoom_in"):
		_set_zoom_level(zoom_level + zoom_factor)
	if event.is_action_pressed("zoom_out"):
		_set_zoom_level(zoom_level - zoom_factor)


func _set_zoom_level(value : float) -> void:
	
	zoom_level = clamp(value, zoom_min, zoom_max)
	
	inverse_zoom = (zoom_level - -zoom_min) / (zoom_max - -zoom_min) * (0.5 - 1.5) + 1.5
	
	var mouse_pos := get_global_mouse_position()
	
	#print(zoom_level)
	
	# camera tweening
	var tween = get_tree().create_tween()
	# tween camera towards zoom direction
	#tween.tween_property(cam, "position", mouse_pos, 0.25)
	# tween the zoom
	#print(zoom_level)
	tween.tween_property(cam, "zoom", Vector2(zoom_level, zoom_level), 0.25)

#func zoom_at_point(zoom_change : float, point) -> void:
#
#	# cam pos
#	var vp_size : Vector2 = get_viewport().size
#	var cam_pos2 : Vector2
#	# zoom level
#	var next_zoom : float = zoom_level * zoom_change
#
#	cam_pos2 = (cam.position - get_global_mouse_position()) * zoom_level / (zoom_level + next_zoom) + get_global_mouse_position()
#
#	cam.position = cam_pos2
#
#	# get old pos
##	var old_pos : Vector2 = cam.position
##	# set new pos
##	cam.position = get_global_mouse_position()
##	# set offset
##	cam.offset = old_pos - get_global_mouse_position() + cam.offset
##
##	# tween
##	var tween = get_tree().create_tween()
##
##	tween.tween_property(cam, "zoom", Vector2(zoom_level + next_zoom, zoom_level + next_zoom), 0.1)
##	tween.tween_property(cam, "offset", Vector2(0, 0), 0.1)
#
##	cam_pos2 = cam.position + (-0.5 * vp_size + point) * (zoom_level - next_zoom)
##	_set_zoom_level(next_zoom)
##	#cam.position = cam_pos2
##	realign_camera()
#
#func realign_camera() -> void:
#	var new_pos := get_global_mouse_position()
#	var displacement = cam.position - new_pos
#
#	cam.position -= displacement
