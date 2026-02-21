shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 0.8, 0.3, 1.0);
uniform float intensity : hint_range(0.0, 2.0) = 0.0;
uniform float pulse_speed : hint_range(0.0, 6.0) = 1.8;
uniform float edge_size : hint_range(0.005, 0.2) = 0.04;

void fragment() {
	vec4 base = texture(TEXTURE, UV) * COLOR;
	float edge = 1.0 - min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y));
	float edge_mask = smoothstep(1.0 - edge_size, 1.0, edge);
	float pulse = 0.65 + 0.35 * sin(TIME * pulse_speed);
	vec3 glow = glow_color.rgb * edge_mask * intensity * pulse;
	COLOR = vec4(base.rgb + glow, base.a);
}
