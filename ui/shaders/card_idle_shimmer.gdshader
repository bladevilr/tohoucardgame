shader_type canvas_item;

uniform vec4 shimmer_color : source_color = vec4(1.0, 1.0, 1.0, 0.35);
uniform float speed : hint_range(0.0, 2.0) = 0.35;
uniform float width : hint_range(0.02, 0.35) = 0.12;

void fragment() {
	vec4 base = texture(TEXTURE, UV) * COLOR;
	float t = fract(TIME * speed);
	float diag = UV.x + UV.y * 0.65;
	float band = smoothstep(t - width, t, diag) * (1.0 - smoothstep(t, t + width, diag));
	base.rgb += shimmer_color.rgb * shimmer_color.a * band;
	COLOR = base;
}
