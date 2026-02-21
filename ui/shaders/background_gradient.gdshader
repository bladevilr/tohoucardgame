shader_type canvas_item;

uniform vec4 color_a : source_color = vec4(0.10, 0.07, 0.16, 1.0);
uniform vec4 color_b : source_color = vec4(0.03, 0.02, 0.05, 1.0);
uniform float motion_speed : hint_range(0.0, 1.0) = 0.08;
uniform float vignette_strength : hint_range(0.0, 2.0) = 0.9;

void fragment() {
	vec2 uv = UV;
	uv += vec2(sin(TIME * motion_speed + uv.y * 5.0), cos(TIME * motion_speed * 1.3 + uv.x * 4.0)) * 0.01;
	float d = distance(uv, vec2(0.5));
	vec3 col = mix(color_a.rgb, color_b.rgb, smoothstep(0.15, 0.9, d));
	float vig = smoothstep(0.45, 0.95, d) * vignette_strength;
	col *= 1.0 - 0.45 * vig;
	COLOR = vec4(col, 1.0);
}
