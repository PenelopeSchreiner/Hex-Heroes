extends PanelContainer


@onready var tile_label = $"MarginContainer/VBoxContainer/Tile Biome"
@onready var elv_label = $"MarginContainer/VBoxContainer/Elv Label"
@onready var rain_label = $"MarginContainer/VBoxContainer/Rain Label"
@onready var node_label = $"MarginContainer/VBoxContainer/Node Label"
@onready var pos_label = $"MarginContainer/VBoxContainer/Pos Label"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_values(tile, elv, rain, node, pos) -> void:
	
	tile_label.text = "Tile: " + str(tile)
	elv_label.text = "Elevation: " + str("%.2f" % elv)
	rain_label.text = "Rainfall: " + str("%.2f" % rain)
	node_label.text = "Node: " + str(node)
	
	pos_label.text = "Pos: " + str(pos)
