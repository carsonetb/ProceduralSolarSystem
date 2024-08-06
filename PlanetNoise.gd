@tool
extends Resource
class_name PlanetNoise

@export var noise_map: FastNoiseLite:
	set(val):
		noise_map = val
		emit_signal("changed")
		
		if noise_map != null && !noise_map.is_connected("changed", on_data_changed):
			noise_map.connect("changed", on_data_changed)
			
@export var amplitude: float = 1.0: 
	set(val):
		amplitude = val
		emit_signal("changed")

@export var noise_multiplier: float = 1.0:
	set(val):
		noise_multiplier = val
		emit_signal("changed")
		
@export var min_height: float = 0.0:
	set(val):
		min_height = val
		emit_signal("changed")
		
@export var use_first_layer_as_mask: bool = false:
	set(val):
		use_first_layer_as_mask = val
		emit_signal("changed")

func on_data_changed():
	emit_signal("changed")
