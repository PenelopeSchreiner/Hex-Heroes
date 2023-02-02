extends Node2D

@onready var player_holder = $Player_Holder

@onready var map = $"hex-map"
var map_tiles

@onready var unitSpawner = $UnitSpawner

var map_size = Vector2i(100, 75)
var world_size := Vector2i(0, 0)

# ----- TILES

var tile_dict = {
	Vector2i(0, 0) : "Water",
	Vector2i(5, 1) : "Snow",
	Vector2i(4, 1) : "Mountain",
	Vector2i(6, 1) : "Tundra",
	Vector2i(2, 1) : "Taiga",
	Vector2i(2, 0) : "Temperate Forest",
	Vector2i(1, 0) : "Tropical Rainforest",
	Vector2i(5, 0) : "Swamp",
	Vector2i(4, 0) : "Temperate Grasslands",
	Vector2i(0, 1) : "Savanna",
	Vector2i(1, 1) : "Desert",
	
	Vector2i(3, 1) : "Debug"
}

var node_types : Array = [
	"Hill",
	"Mountain"
]

#var heat_seed = randi_range(0, 1000000)
var rain_seed = randi_range(0, 1000000)
var elv_seed = randi_range(0, 1000000)

#var heat_noise = FastNoiseLite.new()
var rain_noise = FastNoiseLite.new()
var elv_noise = FastNoiseLite.new()

#var heat_params = [heat_seed, 0.026, 1.5, 4]
var rain_params = [rain_seed, 0.12, 1.0, 4]
var elv_params = [elv_seed, 0.025, 1.0, 4]

# noise values for map
#var heat_n_dict = {}
var rain_n_dict = {}
var elv_n_dict = {}

# - resource/event/terrain nodes
var poi_nodes_dict = {}


# world boundaries
@onready var blocker_left = $Cam_Blocker_Left
@onready var blocker_right = $Cam_Blocker_Right
@onready var blocker_top = $Cam_Blocker_Top
@onready var blocker_bot = $Cam_Blocker_Bot


var prefab_player = preload("res://prefabs/player/player_controller.tscn")
var player_list := []
var local_player

# ----- UI
@onready var tile_tooltip = $"Main Canvas/Tile_Tooltip"
@onready var unit_tooltip = $"Main Canvas/Unit_Tooltip"



# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	map_tiles = map.tile_set
	
	generate_map()
	
	# spawn local player
	local_player = prefab_player.instantiate()
	player_holder.add_child(local_player)
	#local_player.position = map_size / 2 * map.tile_set.tile_size
	local_player.initialize()
	
	# get world size
	world_size = map_size * map.tile_set.tile_size
	world_size.x = world_size.x * 0.75
	
	# - set blockers
	blocker_right.position.x = world_size.x
	blocker_bot.position.y = world_size.y
	
	# -- initialize spawners
	unitSpawner.initialize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_action_just_pressed("debug_regenerate_map"):
		#heat_params[0] = randi_range(0, 1000000)
		rain_params[0] = randi_range(0, 1000000)
		elv_params[0] = randi_range(0, 1000000)
		
		generate_map()


func generate_map():
	
	var land_percent := 0.0
	var tries := 20
	
	while land_percent < 0.4 and tries > 0:
		fillMapWithWater(map_size)
		generateBaseNoise(rain_params, elv_params)
		generateSliomes(map_size)
		set_tiles_based_on_values()
		
		
		fill_poi_nodes()
		clear_nodes_on_map()
		set_nodes_on_map()
		
		land_percent = get_percent_land()
		print(land_percent)
		
		tries -= 1

# - params for noisemaps = [seed, frequency, lacunarity, octaves]
#func generateWorld(size : Vector2i, elevation_params : Array, moisture_params : Array, edge_threshold : int):
#
#	# heat map
##	heat_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
##	heat_noise.seed = elevation_params[0]
##	heat_noise.frequency = elevation_params[1]
##	heat_noise.fractal_lacunarity = elevation_params[2]
##	heat_noise.fractal_octaves = elevation_params[3]
#
#	# - moisture map
#	rain_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
#	rain_noise.seed = moisture_params[0]
#	rain_noise.frequency = moisture_params[1]
#	rain_noise.fractal_lacunarity = moisture_params[2]
#	rain_noise.fractal_octaves = moisture_params[3]
#	# - proximity to map boundaries (closer to the edges
#	#    of the map, more likely to be water)
#	# -- loop through all the tiles within the edge_threshold around all sides and give a chance that they'll be turned to water (70%+)
#
#
#	# - elevation gen
#	for x in size.x:
#		for y in size.y:
#
#			#var heat = heat_noise.get_noise_2d(x, y)
#			var rain = rain_noise.get_noise_2d(x, y)
#
#			# -1 -> 1
#
#			if rain < 0.8:
#				if heat < -0.25:
#					# very cold
#
#					if rain < 0:
#						# tundra
#						map.set_cell(0, Vector2i(x, y), 0, Vector2i(7, 0))
#					else:
#						# snow
#						map.set_cell(0, Vector2i(x, y), 0, Vector2i(4, 0))
#				elif heat < -0.5:
#					# temperate
#
#					if rain < -0.5:
#						# grasslands
#						map.set_cell(0, Vector2i(x, y), 0, Vector2i(6, 0))
#					elif rain < 0:
#						# forest
#						map.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
#
#			else:
#				# water
#				map.set_cell(0, Vector2i(x, y), 0, Vector2i(1, 0))
#
#			if moist < 0.9:
#
#				if heat > 0.75:
#					# mountain top
#					map.set_cell(0, Vector2i(x, y), 0, Vector2i(4, 0))
#				elif heat > 0.55:
#
#					if moist > 0.4:
#						# cloud forest
#						map.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
#					else:
#						# mountain
#						map.set_cell(0, Vector2i(x, y), 0, Vector2i(3, 0))
#				elif heat > 0.35:
#
#					if moist > 0.4:
#						# highlands
#						map.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
#					elif moist < -0.1:
#						# shrublands
#						map.set_cell(0, Vector2i(x, y), 0, Vector2i(7, 0))
#					else:
#						# desert
#						map.set_cell(0, Vector2i(x, y), 0, Vector2i(5, 0))
#				elif heat > 0.15:
#
#					if moist > -0.1:
#						# grasslands
#						map.set_cell(0, Vector2i(x, y), 0, Vector2i(6, 0))
#					else:
#						# savannah
#						map.set_cell(0, Vector2i(x, y), 0, Vector2i(2, 0))
#				elif heat > 0:
#
#					if moist > 0.4:
#						# swamp
#						map.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
#					elif moist > -0.1:
#						# grasslands
#						map.set_cell(0, Vector2i(x, y), 0, Vector2i(6, 0))
#					else:
#						# mid-low desert
#						map.set_cell(0, Vector2i(x, y), 0, Vector2i(5, 0))
#				elif heat > -0.15:
#
#					if moist > 0.6:
#						# swamp
#						map.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
#					elif moist > -0.1:
#						# grasslands
#						map.set_cell(0, Vector2i(x, y), 0, Vector2i(6, 0))
#					else:
#						# low desert/beach
#						map.set_cell(0, Vector2i(x, y), 0, Vector2i(5, 0))
#				else:
#					# water
#					map.set_cell(0, Vector2i(x, y), 0, Vector2i(1, 0))
#			else:
#				# water
#				map.set_cell(0, Vector2i(x, y), 0, Vector2i(1, 0))
	
	
	# - boundary proximity check
#	for x in size.x:
#		for y in size.y:
#			var new_edge = edge_threshold * heat_noise.get_noise_2d(x, y)
#
#			if x > new_edge and x < size.x - new_edge and y > new_edge and y < size.y - new_edge:
#				continue
#
#			var n = randf_range(0.0, 1.0)
#
#			if n < 0.99:
#				# turn tile to water
#				map.set_cell(0, Vector2i(x, y), 0, Vector2i(1, 0))
#
#
#	pass


func fill_poi_nodes() -> void:
	
	for x in map_size.x:
		for y in map_size.y:
			var cell := Vector2i(x, y)
			
			poi_nodes_dict[cell] = "None"

func fillMapWithWater(size : Vector2i):
	for x in size.x:
		for y in size.y:
			map.set_cell(0, Vector2i(x, y), 0, Vector2i(1, 0))

func generateBaseNoise(rainParams : Array, elvParams : Array):
	#heatParams : Array, 
#	heat_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
#	heat_noise.seed = heatParams[0]
#	heat_noise.frequency = heatParams[1]
#	heat_noise.fractal_lacunarity = heatParams[2]
#	heat_noise.fractal_octaves = heatParams[3]
	
	rain_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	rain_noise.seed = rainParams[0]
	rain_noise.frequency = rainParams[1]
	rain_noise.fractal_lacunarity = rainParams[2]
	rain_noise.fractal_octaves = rainParams[3]
	
	elv_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	elv_noise.seed = elvParams[0]
	elv_noise.frequency = elvParams[1]
	elv_noise.fractal_lacunarity = elvParams[2]
	elv_noise.fractal_octaves = elvParams[3]
	
	
	for x in map_size.x:
		for y in map_size.y:
			#heat_n_dict[Vector2i(x, y)] = heat_noise.get_noise_2d(x, y)
			rain_n_dict[Vector2i(x, y)] = rain_noise.get_noise_2d(x, y)
			elv_n_dict[Vector2i(x, y)] = elv_noise.get_noise_2d(x, y)


func generateSliomes(size : Vector2i):
	
	# do x times
	# pick a random spot on the map
	# randomly pick which modifier to use
	# try to spread as far as possible, with a random falloff after each spread
	
	var sliome_num = 50
	
	var falloff_base := 0.0
	var falloff := 0.0
	
	
	for i in sliome_num:
		
		var new_cells_to_check := []
		var cells_to_check := []
		var already_checked := []
		
		# pick random modifier
		var mod = randi_range(2, 5)
		# -- rain +/- 0,1
		# -- temp +/- 2,3
		# -- elevation +/- 4,5
		
		#var ran_id = randi_range(0, 7)
		
		
		while true:
			cells_to_check = new_cells_to_check
			
			if cells_to_check.size() == 0:
				# pick random start
				cells_to_check.append(Vector2i(randi_range(0, size.x - 1), randi_range(0, size.y - 1)))
				
				# reset falloff
				falloff = falloff_base
			
			for cell in cells_to_check:
				# check if can modify cell
				var n = randf_range(0.0, 100.0)
				
				if n > falloff:
					# modify this cell
					
					# -- temp set cell to grass
					#map.set_cell(0, cell, 0, Vector2i(ran_id, 0))
					
					var adjust : float = randf_range(0.01, 0.3)
					
					#if mod == 0:
						# heat down
						#heat_n_dict[cell] -= adjust
					#elif mod == 1:
						# heat up
						#heat_n_dict[cell] += adjust
					if mod == 2:
						# rain down
						rain_n_dict[cell] -= adjust
					elif mod == 3:
						# rain up
						rain_n_dict[cell] += adjust
					elif mod == 4:
						# elv down
						elv_n_dict[cell] -= adjust * 0.25
					elif mod == 5:
						# elv up
						elv_n_dict[cell] += adjust * 0.75
					
					# increase chance to stop spreading
					falloff += randf_range(0.0, 0.15)
					
					# add cell to already checked list
					already_checked.append(cell)
					
					# get all neighbors that haven't been modified yet
					new_cells_to_check.append_array(get_neighbor_cells_not_in_list(cell, already_checked))
				
				# done checking this cell
				cells_to_check.erase(cell)
			
			# done modifying for this sliome
			if cells_to_check.size() == 0:
				break


func set_tiles_based_on_values():
	
	for x in map_size.x:
		for y in map_size.y:
			
			var cell := Vector2i(x, y)
			
			# remap noise values (0.0 -> 1.0)
			#var new_heat_val : float = (heat_n_dict[cell] - -1.0) / (1.0 - -1.0) * (1.0 - 0.0) + 0.0
			var new_rain_val : float = (rain_n_dict[cell] - -1.0) / (1.0 - -1.0) * (1.0 - 0.0) + 0.0
			var new_elv_val : float = (elv_n_dict[cell] - -1.0) / (1.0 - -1.0) * (1.0 - 0.0) + 0.0
			
			# update noise dicts to remapped values
			rain_n_dict[cell] = new_rain_val
			elv_n_dict[cell] = new_elv_val
			
			
			var lat_mod : float = randi_range(0, 3)
			
			
			if new_elv_val > 0.9:
				
				if new_rain_val > 0.5:
					# snowy mountain
					map.set_cell(0, cell, 0, Vector2i(5, 1))
				else:
					# mountain
					map.set_cell(0, cell, 0, Vector2i(4, 1))
			elif new_elv_val < 0.45:
				
				# water
				map.set_cell(0, cell, 0, Vector2i(0, 0))
			else:
				# not water or a mountain
				
				# --- ELV: 0.45 -> 0.9 ---
				
				# ----- NORTH POLE
				
				# 0 -> 13
				if y < map_size.y * 0.05 + lat_mod:
				
					# snow or ice over water
					map.set_cell(0, cell, 0, Vector2i(5, 1))
				elif y < map_size.y * 0.1 + lat_mod:
					
					if new_rain_val > 0.15:
						# tundra
						map.set_cell(0, cell, 0, Vector2i(6, 1))
					else:
						# snow
						map.set_cell(0, cell, 0, Vector2i(5, 1))
				elif y < map_size.y * 0.13 + lat_mod:
					
					if new_rain_val > 0.15:
						# tundra
						map.set_cell(0, cell, 0, Vector2i(6, 1))
					else:
						# snow
						map.set_cell(0, cell, 0, Vector2i(5, 1))
				
				# -----
				
				
				# ----- SOUTH POLE
				
				# map_size.y - 0.13 -> map_size.y
				elif y > map_size.y - map_size.y * 0.05 + lat_mod:
					
					# snow or ice over water
					map.set_cell(0, cell, 0, Vector2i(5, 1))
				elif y > map_size.y - map_size.y * 0.1 + lat_mod:
					
					if new_rain_val > 0.15:
						# tundra
						map.set_cell(0, cell, 0, Vector2i(6, 1))
					else:
						# snow
						map.set_cell(0, cell, 0, Vector2i(5, 1))
				elif y > map_size.y - map_size.y * 0.13 + lat_mod:
					
					if new_rain_val > 0.15:
						# tundra
						map.set_cell(0, cell, 0, Vector2i(6, 1))
					else:
						# snow
						map.set_cell(0, cell, 0, Vector2i(5, 1))
				
				# -----
				
				# ----- EQUATOR
				
				# 50 -> 60
				elif y > map_size.y * 0.50 - lat_mod and y < map_size.y * 0.60 + lat_mod:
					#print("-- Equator span --")
					#print(map_size.y * 0.5 - lat_mod)
					#print(map_size.y * 0.6 + lat_mod)
					# mostly deserts, tropical rainforests, and savannas
					
					if new_elv_val < 0.55:
						# 0.45 -> 0.55
						
						if new_rain_val > 0.65:
							# trop rainforest
							map.set_cell(0, cell, 0, Vector2i(1, 0))
						elif new_rain_val > 0.25:
							# savanna
							map.set_cell(0, cell, 0, Vector2i(0, 1))
						else:
							# desert
							map.set_cell(0, cell, 0, Vector2i(1, 1))
					elif new_elv_val > 0.75:
						# 0.75 -> 0.9
						
						if new_rain_val > 0.4:
							# taiga
							map.set_cell(0, cell, 0, Vector2i(2, 1))
						elif new_rain_val > 0.3:
							# tundra
							map.set_cell(0, cell, 0, Vector2i(6, 1))
						else:
							# mountain
							map.set_cell(0, cell, 0, Vector2i(4, 1))
					else:
						# 0.55 -> 0.75
						
						# more likely to be trop rainforest or savanna
						
						if new_rain_val > 0.65:
							# trop rainforest
							map.set_cell(0, cell, 0, Vector2i(1, 0))
						elif new_rain_val > 0.15:
							# savanna
							map.set_cell(0, cell, 0, Vector2i(0, 1))
						else:
							# desert
							map.set_cell(0, cell, 0, Vector2i(1, 1))
				
				# -----
				
				# ----- SUBTROPICAL
				
				# 35 -> 52
				elif y > map_size.y * 0.35 - lat_mod and y < map_size.y * 0.52 + lat_mod:
					#print("in northern subtrop")
					# - cooler but more varied than closer to the equator
					
					if new_elv_val < 0.65:
						# lower elevations
						
						if new_rain_val > 0.55:
							# - higher chance to be swamp
							
							var n = randf_range(0.0, 100.0)
							
							if n > 65.0:
								# swamp
								map.set_cell(0, cell, 0, Vector2i(5, 0))
							else:
								# trop rainforest
								map.set_cell(0, cell, 0, Vector2i(1, 0))
						elif new_rain_val > 0.3:
							
							#var n = randf_range(0.0, 100.0)
							
							#if n > 75.0:
								# savanna
							map.set_cell(0, cell, 0, Vector2i(0, 1))
							#else:
								# temp grassland
							#	map.set_cell(0, cell, 0, Vector2i(4, 0))
						else:
							# desert
							map.set_cell(0, cell, 0, Vector2i(1, 1))
					elif new_elv_val > 0.75:
						# 0.75 - 0.9
						
						if new_rain_val > 0.4:
							# taiga
							map.set_cell(0, cell, 0, Vector2i(2, 1))
						else:
							# mountain
							map.set_cell(0, cell, 0, Vector2i(4, 1))
					else:
						# 0.65 -> 0.75
						
						if new_rain_val > 0.5:
							# wetter and cooler
							# trop forest
							map.set_cell(0, cell, 0, Vector2i(1, 0))
						else:
							# desert
							map.set_cell(0, cell, 0, Vector2i(1, 1))
				
				# 58 -> 75
				elif y > map_size.y * 0.58 - lat_mod and y < map_size.y * 0.75 + lat_mod:
					# - cooler but more varied than closer to the equator
					
					if new_elv_val < 0.65:
						# lower elevations
						
						if new_rain_val > 0.55:
							# - higher chance to be swamp
							
							var n = randf_range(0.0, 100.0)
							
							if n > 65.0:
								# swamp
								map.set_cell(0, cell, 0, Vector2i(5, 0))
							else:
								# trop rainforest
								map.set_cell(0, cell, 0, Vector2i(1, 0))
						elif new_rain_val > 0.3:
							
							#var n = randf_range(0.0, 100.0)
							
							#if n > 75.0:
								# savanna
							map.set_cell(0, cell, 0, Vector2i(0, 1))
							#else:
								# temp grassland
							#	map.set_cell(0, cell, 0, Vector2i(4, 0))
						else:
							# desert
							map.set_cell(0, cell, 0, Vector2i(1, 1))
					elif new_elv_val > 0.75:
						# 0.75 - 0.9
						
						if new_rain_val > 0.4:
							# taiga
							map.set_cell(0, cell, 0, Vector2i(2, 1))
						else:
							# mountain
							map.set_cell(0, cell, 0, Vector2i(4, 1))
					else:
						# 0.65 -> 0.75
						
						if new_rain_val > 0.5:
							# wetter and cooler
							# trop forest
							map.set_cell(0, cell, 0, Vector2i(1, 0))
						else:
							# desert
							map.set_cell(0, cell, 0, Vector2i(1, 1))
				# -----
				
				# 13 -> 35
				# 75 -> 88
				else:
					
					#print(str(y) + ", " + str(cell))
					# --- between the poles and subtrop regions
					#map.set_cell(0, cell, 0, Vector2i(3, 1))
					
					if new_elv_val > 0.7:
						# taiga or tundra

						if new_rain_val > 0.3:
							# taiga
							map.set_cell(0, cell, 0, Vector2i(2, 1))
						else:
							# tundra
							map.set_cell(0, cell, 0, Vector2i(6, 1))
					elif new_elv_val > 0.5:
						# colder and higher

						if new_rain_val > 0.65:
							# temp forest
							map.set_cell(0, cell, 0, Vector2i(2, 0))
						elif new_rain_val > 0.3:
							# temp grasslands
							map.set_cell(0, cell, 0, Vector2i(4, 0))
						else:
							# desert
							map.set_cell(0, cell, 0, Vector2i(1, 1))
					else:
						# lower and warmer

						if new_rain_val > 0.6:
							# temp forest
							map.set_cell(0, cell, 0, Vector2i(2, 0))
						elif new_rain_val > 0.3:
							# temp grasslands
							map.set_cell(0, cell, 0, Vector2i(4, 0))
						else:
							# desert
							map.set_cell(0, cell, 0, Vector2i(1, 1))


func clear_nodes_on_map():
	
	for x in map_size.x:
		for y in map_size.y:
			
			var cell := Vector2i(x, y)
			
			map.set_cell(1, cell, -1)

func set_nodes_on_map():
	# use noise values and node generation to place
	# nodes on the map, resource and terrain nodes
	
	for x in map_size.x:
		for y in map_size.y:
			
			var cell := Vector2i(x, y)
			
			#var new_rain_val : float = (rain_n_dict[cell] - -1.0) / (1.0 - -1.0) * (1.0 - 0.0) + 0.0
			#var new_elv_val : float = (elv_n_dict[cell] - -1.0) / (1.0 - -1.0) * (1.0 - 0.0) + 0.0
			
			
			# ----- TERRAIN NODES
			
			if elv_n_dict[cell] > 0.9:
				# mountain
				map.set_cell(1, cell, 1, Vector2i(1, 0))
				
				# - update nodes dict
				poi_nodes_dict[cell] = node_types[1]
			elif elv_n_dict[cell] > 0.7:
				# hills
				map.set_cell(1, cell, 1, Vector2i(0, 0))
			
				# - update nodes dict
				poi_nodes_dict[cell] = node_types[0]
			# -----
	

func get_neighbor_cells(pos : Vector2i) -> Array:
	var arr := []
	
	# make sure a cell isn't empty
	var t = map.get_surrounding_cells(pos)
	
	for i in t:
		if map.get_cell_tile_data(0, i) != null:
			arr.append(i)
			
			#map.set_cell(0, i, 0, Vector2i(0, 0))
	
	return arr


func get_neighbor_cells_not_in_list(pos : Vector2i, exempt_list : Array) -> Array:
	var arr := []
	
	var t = map.get_surrounding_cells(pos)
	
	for i in t:
		
		if map.get_cell_tile_data(0, i) == null:
			continue
			
		if exempt_list.has(i) == false:
			
			if i.x >= 0 and i.x < map_size.x and i.y >= 0 and i.y < map_size.y:
				arr.append(i)
			
			#map.set_cell(0, i, 0, Vector2i(0, 0))
	
	return arr


func get_percent_land() -> float:
	
	var used_cells : Array = map.get_used_cells(0)
	
	var total_cells := used_cells.size()
	var land_cells := 0
	
	for cell in used_cells:
		# --- MAKE SURE TO USE THE ATLAS COORD OF THE WATER TILE
		if map.get_cell_atlas_coords(0, cell) != Vector2i(0, 0):
			land_cells += 1
	
	return float(land_cells) / float(total_cells)


func get_map() -> Node:
	return map

func get_player_holder() -> Node:
	return player_holder


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		
		if local_player.selector.visible == false:
			local_player.selector.show()
		
		var local_pos = map.get_global_mouse_position()
		var map_pos = map.local_to_map(Vector2i(round(local_pos.x), round(local_pos.y)))
		
		if map_pos.x >= 0 and map_pos.x < map_size.x and map_pos.y >= 0 and map_pos.y < map_size.y:
			local_player.selector.position = map.map_to_local(map_pos)
			
			# get tile data
			var elv : float = elv_n_dict[map_pos]
			var rain : float = rain_n_dict[map_pos]
			var node : String = poi_nodes_dict[map_pos]
			
			tile_tooltip.set_values(tile_dict[map.get_cell_atlas_coords(0, map_pos)], elv, rain, node, map_pos)
			
			
			# get unit data
			var spawned_units : Array = unitSpawner.spawned_units
			
			for u in spawned_units:
				if u.grid_pos == map_pos:
					print("unit at: " + str(map_pos))
					# there is a unit on this tile
					unit_tooltip.set_values(u.unit_name)
