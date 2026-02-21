shader_type canvas_item;

uniform vec4 pulse_color : source_color = vec4(0.25, 0.95, 0.45, 1.0);
uniform float pulse_strength : hint_range(0.0, 1.5) = 0.0;
uniform float pulse_speed : hint_range(0.0, 6.0) = 2.4;

void fragment() {
	vec4 base = texture(TEXTURE, UV) * COLOR;
	float edge = 1.0 - min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y));
	float border = smoothstep(0.88, 1.0, edge);
	float pulse = 0.55 + 0.45 * sin(TIME * pulse_speed);
	base.rgb += pulse_color.rgb * border * pulse_strength * pulse;
	COLOR = base;
}
