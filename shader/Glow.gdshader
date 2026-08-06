shader_type spatial;
// note: this shader was reworked Entirely, so some comments are still Old.

// Box size in local space
uniform vec3 box_size = vec3(600.0, 600.0, 600.0);

// Controls
uniform float Glowness = 2.0;
uniform float bness = 1.0;
uniform float fall_off_scale = 3.0;
uniform float b_offset = 0.0;

// Colors
uniform vec3 base_color : source_color = vec3(1.0, 0.85, 0.05);
uniform vec3 glow_color : source_color = vec3(1.0, 0.38, 0.05);


float distance_to_box(vec3 point, vec3 box_half_size) {
    vec3 d = abs(point) - box_half_size;
    return length(max(d, vec3(0.0)));
}

void fragment() {
    // Convert local vertex to world position
    vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

    // Center of the object in world space
    vec3 world_center = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;

    // Vector from center to fragment
    vec3 to_frag = world_pos - world_center;

    // Distance to box
    float d2c = distance_to_box(to_frag, box_size);

    // Falloff brightness
    float alpha = -log(d2c * fall_off_scale + b_offset) * bness;
    alpha = clamp(alpha, 0.0, 1.0);


    // Object color
    ALBEDO = base_color;

    // Transparency
    ALPHA = alpha;

    // Glow color (independent from object color)
    EMISSION = glow_color * alpha * Glowness;
}