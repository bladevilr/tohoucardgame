shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
// 聚光灯改为极淡的暖光，仅作氛围润色，不再作为主光源
uniform vec4 spotlight_color : source_color = vec4(1.0, 0.95, 0.8, 0.05);
uniform vec2 mouse_pos = vec2(0.5, 0.5);

// 外部纹理输入
uniform sampler2D diffuse_texture : filter_linear_mipmap, repeat_enable;
uniform sampler2D normal_texture : filter_linear_mipmap, repeat_enable;
uniform bool use_texture = false;

void fragment() {
	vec2 uv = UV;
	
	vec3 col = base_color.rgb;
	vec3 normal = vec3(0.5, 0.5, 1.0);
	
	if (use_texture) {
		col *= texture(diffuse_texture, uv).rgb;
		// 稍微混合一点白色，让木纹没那么深沉，增加通透感
		col = mix(col, vec3(0.15, 0.12, 0.15), 0.1); 
		normal = texture(normal_texture, uv).rgb;
	} else {
		float grain = sin(uv.y * 200.0 + uv.x * 5.0) * 0.02;
		col += grain;
	}
	
	// 光照计算优化：光源拉高，减少剧烈阴影
	vec3 n = normalize(normal * 2.0 - 1.0);
	// 将光源Z轴从0.2拉高到1.5，光照变得非常平滑均匀
	vec3 light_pos = vec3(mouse_pos, 1.5);
	vec3 frag_pos = vec3(uv, 0.0);
	vec3 light_dir = normalize(light_pos - frag_pos);
	
	// 漫反射强度减弱，防止过曝或过暗
	float diff = max(dot(n, light_dir), 0.0);
	
	// 基础环境光大幅提升 (0.6 -> 0.85)，减少阴影死黑
	col *= (0.85 + diff * 0.15); 
	
	// 聚光灯逻辑
	vec2 aspect_uv = vec2(uv.x * 1.77, uv.y);
	vec2 aspect_mouse = vec2(mouse_pos.x * 1.77, mouse_pos.y);
	float dist = distance(aspect_uv, aspect_mouse);
	// 光斑范围变大，边缘变柔和
	float spot = smoothstep(1.2, 0.0, dist); 
	
	col += spotlight_color.rgb * spot * spotlight_color.a;
	
	// 暗角大幅减弱，只在最边缘有一点点
	float vign = distance(uv, vec2(0.5));
	col *= 1.0 - smoothstep(0.65, 1.8, vign) * 0.4;
	
	COLOR = vec4(col, 1.0);
}
