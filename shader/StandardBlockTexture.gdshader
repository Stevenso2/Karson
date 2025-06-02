shader_type spatial;

uniform float LineW = 0.2;
uniform float texSize = 5;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 BG = vec3(0.05,0.05,0.05);
	vec3 FG = vec3(0.005,0.005,0.005);


	float depth = FRAGCOORD.z;
	vec2 frag_ndc = ((FRAGCOORD.xy / VIEWPORT_SIZE) * 2.0) - 1.0;
	vec4 frag_view_space_position = INV_PROJECTION_MATRIX * vec4(frag_ndc, depth, 1.0);
	frag_view_space_position /= frag_view_space_position.w;
	vec4 frag_world_space = (INV_VIEW_MATRIX * frag_view_space_position);

	ALBEDO = BG;
	float fragx = mod(frag_world_space.x, texSize);
	if (fragx >= 0.001 && fragx <= LineW) {
		ALBEDO = FG;
	};
	float fragy = mod(frag_world_space.y, texSize);
	if (fragy >= 0.001 && fragy <= LineW) {
		ALBEDO = FG;
	};
	float fragz = mod(frag_world_space.z, texSize);
	if (fragz >= 0.001 && fragz <= LineW) {
		ALBEDO = FG;
	};
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
