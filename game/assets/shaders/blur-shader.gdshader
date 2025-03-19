shader_type canvas_item;
render_mode blend_mix; // Safe default blending

uniform float blur_amount : hint_range(0.0, 10.0, 0.1) = 2.0; // Adjustable blur strength

// Gaussian weights for a 5x5 kernel (normalized to ~1.0)
const float weights[3] = float[](0.227027, 0.1945946, 0.054054); // Center, 1-step, 2-step

void fragment() {
	// Use UV for texture sampling
	vec2 uv = UV;
	vec2 pixel_offset = blur_amount * SCREEN_PIXEL_SIZE; // Dynamic offset based on screen pixels

	// 5x5 Gaussian blur
	vec4 sum = vec4(0.0);
	for (int x = -2; x <= 2; x++) {
		for (int y = -2; y <= 2; y++) {
			vec2 offset = vec2(float(x), float(y)) * pixel_offset;
			int dist = max(abs(x), abs(y)); // Distance from center (0, 1, or 2)
			float weight = weights[min(dist, 2)]; // Safe weight access
			sum += texture(TEXTURE, uv + offset) * weight;
		}
	}

	// Fallback to original texture if sum is invalid
	if (sum.a == 0.0 || sum.rgb == vec3(0.0)) {
		COLOR = texture(TEXTURE, uv); // Show original if blur fails
	} else {
		COLOR = sum;
	}
}