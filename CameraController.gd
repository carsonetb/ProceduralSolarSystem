extends Camera3D


var speed_multiplier = 0.01
@onready var current_planet = get_parent().get_node("Earth")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !Input.is_action_pressed("rclick"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	if Input.is_action_pressed("left"):
		position -= global_transform.basis.x * delta * 60 * speed_multiplier / Engine.time_scale
	if Input.is_action_pressed("right"):
		position += global_transform.basis.x * delta * 60 * speed_multiplier / Engine.time_scale
	if Input.is_action_pressed("forward"):
		position -= global_transform.basis.z * delta * 60 * speed_multiplier / Engine.time_scale
	if Input.is_action_pressed("backward"):
		position += global_transform.basis.z * delta * 60 * speed_multiplier / Engine.time_scale
	
	if Input.is_action_pressed("shift"):
		if Input.is_action_just_pressed("decrease_speed"):
			fov += 5
		if Input.is_action_just_pressed("increase_speed"):
			fov -= 5
		fov = clamp(fov, 0, 75)
	else:
		if Input.is_action_just_pressed("decrease_speed"):
			speed_multiplier /= 1.2
		if Input.is_action_just_pressed("increase_speed"):
			speed_multiplier *= 1.2
		
	if Input.is_action_just_pressed("slow_down_time"):
		Engine.time_scale /= 1.2
	if Input.is_action_just_pressed("speed_up_time"):
		Engine.time_scale *= 1.2
		
	$Label3D.text = str(snapped(speed_multiplier * 100 * 100, 0.01)) + "%, " + str(snapped(Engine.time_scale, 0.01)) + "x time"
	
	position += current_planet.position - current_planet.previous_position

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			rotation_degrees.y -= event.relative.x / (90 - fov)
			rotation_degrees.x -= event.relative.y / (90 - fov)
