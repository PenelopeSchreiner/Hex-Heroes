extends Node2D
class_name Unit

var id : String

var unit_name : String
var unit_tex : Texture2D

var grid_pos : Vector2i

var hp_cur : int
var hp_max : int
var attack : float
var defence : float
var satiation : float
var encumberance : float

var travel_speed := 2.5
var cur_move_type : MovementType
var possible_move_types := []


enum MovementType {
	Ground,
	Flying,
	Swimming
}



# -- virtual functions --

func on_target():
	return

func on_detarget():
	return

func on_move():
	return

# interactions, attacks, spells, etc
func on_action():
	return

func on_hit():
	return

func on_damaged():
	return

func on_death():
	return

func on_healed():
	return
