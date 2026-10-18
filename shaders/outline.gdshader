shader_type canvas_item;

uniform bool include_corners = true;
uniform vec4 outline_color: source_color = vec4(0.0f, 0.0f, 0.0f, 0.0f);

bool valid_UV(vec2 uv) {
	return 0.0f < uv.x && uv.x < 1.0f 
			&& 0.0f < uv.y && uv.y < 1.0f;
}

bool is_opaque(vec2 uv, sampler2D comp_texture) {
	return valid_UV(uv) && texture(comp_texture, uv). a > 0.2f;
}

void vertex() {
	VERTEX += (VERTEX * 2.0f * TEXTURE_PIXEL_SIZE - vec2(1.0f));
}

void fragment() {
	vec2 SIZE_PIXELS = vec2(1.0f) / TEXTURE_PIXEL_SIZE;
	vec2 EXPANDED_SIZE_PIXELS = SIZE_PIXELS + vec2(2.0f);
	
	vec2 old_UV = UV * EXPANDED_SIZE_PIXELS - vec2(1.0f);
	old_UV *= TEXTURE_PIXEL_SIZE;
	vec4 base;
	if(valid_UV(old_UV)) {
		base = texture(TEXTURE, old_UV);
	}
	else {
		base = vec4(0.0f);
	}
	
	if (base.a < 0.2f) {
		vec2 neighbors[] = {
			old_UV + vec2(TEXTURE_PIXEL_SIZE.x, 0.0f),
			old_UV + vec2(0.0f, TEXTURE_PIXEL_SIZE.y),
			old_UV + vec2(-TEXTURE_PIXEL_SIZE.x, 0.0f),
			old_UV + vec2(0.0f, -TEXTURE_PIXEL_SIZE.y)
		};
		
		bool is_edge = is_opaque(neighbors[0], TEXTURE)
				|| is_opaque(neighbors[1], TEXTURE)
				|| is_opaque(neighbors[2], TEXTURE)
				|| is_opaque(neighbors[3], TEXTURE);
		
		vec2 corner_neighbors[] = {
			old_UV + vec2(TEXTURE_PIXEL_SIZE.x, TEXTURE_PIXEL_SIZE.y),
			old_UV + vec2(-TEXTURE_PIXEL_SIZE.x, TEXTURE_PIXEL_SIZE.y),
			old_UV + vec2(-TEXTURE_PIXEL_SIZE.x, -TEXTURE_PIXEL_SIZE.y),
			old_UV + vec2(TEXTURE_PIXEL_SIZE.x, -TEXTURE_PIXEL_SIZE.y)
		};
		
		bool is_corner = is_opaque(corner_neighbors[0], TEXTURE)
				|| is_opaque(corner_neighbors[1], TEXTURE)
				|| is_opaque(corner_neighbors[2], TEXTURE)
				|| is_opaque(corner_neighbors[3], TEXTURE);
		
		if (is_edge || (include_corners && is_corner)) {
			COLOR = outline_color;
		}
		else {
			COLOR = base;
		}
	}
	else {
		COLOR = base;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
