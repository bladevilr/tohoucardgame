shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec4 edge_color : source_color = vec4(1.0, 0.9, 0.3, 1.0);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(31.2, 17.3))) * 43758.5453);
}

void fragment() {
	vec4 base = texture(TEXTURE, UV) * COLOR;
	float n = hash(floor(UV * 50.0));
	float threshold = progress;
	float edge = smoothstep(threshold - 0.03, threshold, n) - smoothstep(threshold, threshold + 0.03, n);
	float visible = step(threshold, n);
	vec3 col = mix(edge_color.rgb, base.rgb, visible);
	col = mix(col, edge_color.rgb, edge);
	COLOR = vec4(col, base.a * visible);
}
