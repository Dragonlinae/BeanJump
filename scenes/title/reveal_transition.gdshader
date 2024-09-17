shader_type canvas_item;

uniform float offset : hint_range(0, 2500) = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
	VERTEX += vec2(offset, 0.0);
}

void fragment() {
	// Substitue with screen texture but keep alpha
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}

