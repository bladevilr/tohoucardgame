shader_type canvas_item;

uniform vec4 fill_a : source_color = vec4(0.20, 0.65, 1.0, 1.0);
uniform vec4 fill_b : source_color = vec4(0.15, 0.45, 0.95, 1.0);
uniform float shine_speed : hint_range(0.0, 2.0) = 0.55;

void fragment() {
	vec4 base = texture(TEXTURE, UV) * COLOR;
	vec3 grad = mix(fill_a.rgb, fill_b.rgb, UV.y);
	float shine = smoothstep(0.0, 0.2, UV.x + fract(TIME * shine_speed)) * (1.0 - smoothstep(0.2, 0.45, UV.x + fract(TIME * shine_speed)));
	base.rgb = mix(base.rgb, grad + vec3(shine * 0.3), 0.85);
	COLOR = base;
}
