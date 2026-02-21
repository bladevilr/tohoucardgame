shader_type canvas_item;

uniform vec4 bg_color : source_color = vec4(0.15, 0.12, 0.18, 0.9);
uniform vec4 pattern_color : source_color = vec4(0.25, 0.22, 0.30, 0.5);
uniform float scale : hint_range(10.0, 100.0) = 50.0;

void fragment() {
	vec2 uv = UV * scale;
	
	// 菱形/网格图案
	vec2 f = fract(uv);
	float d = min(min(f.x, 1.0-f.x), min(f.y, 1.0-f.y));
	float pattern = smoothstep(0.0, 0.1, d) - smoothstep(0.1, 0.2, d);
	
	// 编织感噪声
	float noise = sin(uv.x * 2.0) * sin(uv.y * 2.0) * 0.1;
	
	vec4 col = bg_color;
	col.rgb += pattern_color.rgb * pattern;
	col.rgb += noise;
	
	// 边缘光
	float dist = distance(UV, vec2(0.5));
	col.rgb *= 1.0 - smoothstep(0.4, 0.8, dist) * 0.5;
	
	COLOR = col;
}
