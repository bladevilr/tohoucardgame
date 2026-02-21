shader_type canvas_item;

uniform float greasy_intensity : hint_range(0.0, 1.0) = 0.0;
uniform float fatigue_intensity : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	float ripple = sin((UV.y + TIME * 0.35) * 32.0 + UV.x * 6.0) * 0.08 * greasy_intensity;
	vec3 greasy = vec3(0.48, 0.34, 0.16) * (0.55 + ripple);
	vec3 fatigue = vec3(0.42);
	vec3 tint = mix(greasy, fatigue, fatigue_intensity);
	float alpha = (greasy_intensity * 0.5 + fatigue_intensity * 0.6) * COLOR.a;
	COLOR = vec4(tint, alpha);
}
