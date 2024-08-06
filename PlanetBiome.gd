@tool
extends Resource
class_name PlanetBiome

@export var gradient: GradientTexture1D:
	set(val):
		gradient = val
		emit_signal("changed")
		if gradient != null and not gradient.is_connected("changed", on_data_changed):
			gradient.connect("changed", on_data_changed)
		
@export var start_height: float: 
	set(val):
		start_height = val
		emit_signal("changed")

func on_data_changed():
	emit_signal("changed")
