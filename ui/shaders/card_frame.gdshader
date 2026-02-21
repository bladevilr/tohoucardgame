shader_type canvas_item;

uniform vec4 border_color : source_color = vec4(0.9, 0.75, 0.3, 1.0);
uniform int tier = 0;
uniform float border_width : hint_range(0.005, 0.1) = 0.02;

float border_mask(vec2 uv, float w) {
	float x = min(uv.x, 1.0 - uv.x);
	float y = min(uv.y, 1.0 - uv.y);
	return 1.0 - step(w, min(x, y));
}

void fragment() {
	vec4 base = texture(TEXTURE, UV) * COLOR;
	float b1 = border_mask(UV, border_width);
	float b2 = border_mask(UV, border_width * 2.2) - b1;
	float b3 = border_mask(UV, border_width * 3.3) - b1 - b2;

	float deco = b1;
	if (tier >= 1) {
		deco += max(b2, 0.0) * 0.7;
	}
	if (tier >= 2) {
		deco += max(b3, 0.0) * 0.55;
	}
	if (tier >= 3) {
		float wave = 0.35 + 0.35 * sin(TIME * 1.4 + UV.x * 9.0);
		deco += wave * b1;
	}
	base.rgb += border_color.rgb * deco;
	COLOR = base;
}
