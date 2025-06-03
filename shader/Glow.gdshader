shader_type spatial;

// Box size in local space [Pizzi note: this is a temp fix but it works xD]
uniform vec3 box_size = vec3(600.0, 600.0, 600.0);

// Controls
uniform float Glowness = 2;
uniform float bness = 1.0;
uniform float fall_off_scale = 3.0;
uniform float b_offset = 0.0;


float distance_to_box(vec3 point, vec3 box_half_size) {
    vec3 d = abs(point) - box_half_size;
    return length(max(d, vec3(0.0)));
}

void fragment() {
    // Convert local vertex to world position
    vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

    // Center of the object in world space
    vec3 world_center = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;

    // Compute vector from center to this fragment in world space
    vec3 to_frag = world_pos - world_center;

    // Distance to box in world space
    float d2c = distance_to_box(to_frag, box_size);

    // falloff for brightness
    float alpha = -log(d2c * fall_off_scale + b_offset) * bness;
    alpha = clamp(alpha, 0.0, 1.0);

    vec3 base_color = vec3(1.0, 0.18, 0.05);  // 1.0, 0.35, 0.05 = warm orange , 1.0, 0.5, 0.0 = normal orange, normal set it to 1.0, 0.18, 0.05

    ALBEDO = base_color;
    ALPHA = alpha;

    // Optional emissive effect
	EMISSION = base_color * alpha * Glowness; // how much glow should be added , set to 1.0 to dissable glow

}
