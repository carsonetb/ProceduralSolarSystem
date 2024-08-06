@tool
extends Resource
class_name PlanetData

@export var radius := 1.0:
	set(val):
		radius = val
		emit_signal("changed")

@export var resolution := 1:
	set(val):
		resolution = val
		emit_signal("changed")
		
@export var planet_noise: Array[PlanetNoise]:
	set(val):
		planet_noise = val
		emit_signal("changed")
		for i in range(planet_noise.size()):
			if planet_noise[i] == null:
				planet_noise[i] = PlanetNoise.new()
				planet_noise[i].noise_map = FastNoiseLite.new()
			if planet_noise[i] != null && !planet_noise[i].is_connected("changed", on_data_changed):
				planet_noise[i].connect("changed", on_data_changed)

@export var biomes: Array[PlanetBiome]: 
	set(val):
		biomes = val
		for i in range(biomes.size()):
			if biomes[i] == null:
				biomes[i] = PlanetBiome.new()
			if biomes[i] != null && !biomes[i].is_connected("changed", on_data_changed):
				biomes[i].connect("changed", on_data_changed)

@export var biome_noise: FastNoiseLite:
	set(val):
		biome_noise = val
		emit_signal("changed")
		if biome_noise != null and not biome_noise.is_connected("changed", on_data_changed):
			biome_noise.connect("changed", on_data_changed)
		
@export var biome_amplitude: float:
	set(val):
		biome_amplitude = val
		emit_signal("changed")

@export var biome_offset: float:
	set(val):
		biome_offset = val
		emit_signal("changed")
		
@export_range (0.0, 1.0) var biome_blend: float: 
	set(val):
		biome_blend = val
		emit_signal("changed")

var min_height := 999999.0
var max_height := -999999.0

func on_data_changed():
	emit_signal("changed")

func point_on_planet(point_on_sphere: Vector3) -> Vector3:
	var elevation: float = 0.0
	var base_elevation:= 0.0
	
	if planet_noise.size() > 0:
		base_elevation = (planet_noise[0].noise_map.get_noise_3dv(point_on_sphere * 100 * planet_noise[0].noise_multiplier) / 2 + 1) * planet_noise[0].amplitude
		base_elevation = max(0.0, base_elevation - planet_noise[0].min_height)
	
	for n in planet_noise:
		var mask = 1.0
		
		if n.use_first_layer_as_mask:
			mask = base_elevation
		
		var level_elevation = (n.noise_map.get_noise_3dv(point_on_sphere * 100 * n.noise_multiplier) / 2 + 1) * n.amplitude
		level_elevation = max(0.0, level_elevation - n.min_height) * mask
		elevation += level_elevation
	
	return point_on_sphere * radius * (elevation + 1)

func update_biome_texture() -> ImageTexture:
	var image_texture = ImageTexture.new()
	var dynamic_image = Image.new()
	
	var h: int = biomes.size()
	if h > 0:
		var data: PackedByteArray
		var w: int = biomes[0].gradient.width
		for b in biomes:
			data.append_array(b.gradient.get_image().get_data())
			
		dynamic_image = Image.create_from_data(w, h, false, Image.FORMAT_RGBA8, data)
		image_texture = ImageTexture.create_from_image(dynamic_image)
		image_texture.resource_name = "Biome Texture"
	
	return image_texture

func biome_percent_from_point(point_on_unit_sphere: Vector3) -> float:
	var height_percent: float = (point_on_unit_sphere.y + 1.0) / 2.0
	height_percent += ((biome_noise.get_noise_3dv(point_on_unit_sphere * 100) / 2 + 1) - biome_offset) * biome_amplitude
	
	var biome_index: float = 0.0
	var num_biome: float = biomes.size()
	var blend_range: float = biome_blend / 2
	
	for i in range(num_biome):
		var dst: float = height_percent - biomes[i].start_height
		var lerp_val = clamp(inverse_lerp(-blend_range, blend_range, dst), 0.0, 1.0)
		var weight: float = lerp_val
		biome_index *= (1-weight)
		biome_index += i * weight
		
	return biome_index / max(1.0, num_biome - 1)
