shader_type spatial;

uniform vec2 shape_position;
uniform float shape_radius : hint_range(0.0, 1.0); // Radius of the circle
uniform vec3 shape_color; // Color inside the shape
uniform vec3 background_color; // Background color

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
    // Calculate the distance from the current fragment to the shape's position
    float distance = distance(UV, shape_position);

    // If the distance is less than the shape radius, use the shape color; otherwise, use the background color
    if (distance < shape_radius) {
        ALBEDO = shape_color;
    } else {
        ALBEDO = background_color;
    }
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
