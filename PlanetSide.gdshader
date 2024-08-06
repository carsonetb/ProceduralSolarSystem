shader_type spatial;

uniform float min_height;
uniform float max_height;
uniform sampler2D height_color: filter_nearest;

varying float height;

void vertex() {
	height = length(VERTEX);
}

void fragment() {
	float t = height / (max_height - min_height) - (min_height / (max_height - min_height)); 
	
	float modified_uv = UV.y;
	if (UV.y > 0.0) {
		modified_uv = modified_uv - 0.01;
	}
	
	vec3 color = texture(height_color, vec2(t, modified_uv)).rgb;
	ALBEDO = color;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
