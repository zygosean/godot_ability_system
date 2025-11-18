shader_type spatial;

// Render backfaces instead of front faces:
render_mode unshaded, cull_front;

// Customizable outline colour and thickness:
uniform vec4 outline_colour : source_color = vec4(1.0, 0.8, 0.0, 1.0);
uniform float outline_thickness : hint_range(0.0, 0.2) = 0.05;

// Expand each vertex outward along its normal:
void vertex() {
	VERTEX += NORMAL * outline_thickness;
}

void fragment() {
	ALBEDO = outline_colour.rgb;
	ALPHA = outline_colour.a;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
