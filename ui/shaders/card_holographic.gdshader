shader_type canvas_item;

uniform float speed : hint_range(0.0, 1.0) = 0.18;
uniform float intensity : hint_range(0.0, 1.0) = 0.35;

vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
	vec4 base = texture(TEXTURE, UV) * COLOR;
	float h = fract(UV.x * 1.6 + UV.y * 0.6 + TIME * speed);
	vec3 holo = hsv2rgb(vec3(h, 0.65, 1.0));
	base.rgb = mix(base.rgb, base.rgb + holo, intensity);
	COLOR = base;
}
