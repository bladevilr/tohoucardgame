shader_type canvas_item;

// 材质属性
uniform vec4 base_color : source_color = vec4(0.1, 0.1, 0.1, 1.0);
uniform vec4 border_color : source_color = vec4(0.9, 0.75, 0.3, 1.0);
uniform int tier = 0; // 0=Bronze, 1=Silver, 2=Gold, 3=Diamond

// 外部纹理输入
uniform sampler2D base_texture : filter_linear_mipmap, repeat_enable;
uniform bool use_texture = false;

// 动态交互
uniform vec2 mouse_pos; // 归一化鼠标位置 (0.0 - 1.0)
uniform float intensity : hint_range(0.0, 1.0) = 0.0; // 悬浮强度

// 模拟边框的法线贴图效果
vec3 get_normal(vec2 uv, float width) {
	vec3 normal = vec3(0.0, 0.0, 1.0);
	
	// 边缘倒角模拟
	float dist_x = min(uv.x, 1.0 - uv.x);
	float dist_y = min(uv.y, 1.0 - uv.y);
	float dist = min(dist_x, dist_y);
	
	if (dist < width) {
		float slope = (width - dist) / width;
		if (dist_x < width) normal.x = sign(uv.x - 0.5) * slope;
		if (dist_y < width) normal.y = sign(uv.y - 0.5) * slope;
		normal.z = sqrt(1.0 - normal.x*normal.x - normal.y*normal.y);
	}
	
	// 内部装饰纹理的法线扰动 (减弱扰动幅度)
	if (tier >= 2) {
		float pattern = sin(uv.x * 20.0 + uv.y * 20.0);
		if (dist > width && dist < width * 2.0 && pattern > 0.0) {
			normal.z *= 0.9; // 0.8 -> 0.9 (更平滑)
		}
	}
	
	return normalize(normal);
}

void fragment() {
	vec2 uv = UV;
	
	vec4 tex_color = vec4(1.0);
	if (use_texture) {
		tex_color = texture(base_texture, uv);
	}
	
	float width = 0.03;
	float dist_x = min(uv.x, 1.0 - uv.x);
	float dist_y = min(uv.y, 1.0 - uv.y);
	float border_mask = 1.0 - step(width, min(dist_x, dist_y));
	
	if (tier >= 1) {
		float inner_width = width * 0.4;
		float inner_dist = min(dist_x, dist_y);
		float deco = 1.0 - step(width * 2.0, inner_dist);
		deco *= step(width * 1.5, inner_dist);
		border_mask += deco;
	}

	vec3 albedo = base_color.rgb;
	if (border_mask > 0.5) {
		albedo = border_color.rgb;
		if (use_texture) {
			// 减弱纹理混合对比度，让颜色更纯净
			albedo = mix(albedo, albedo * tex_color.rgb, 0.6); 
		}
	}
	
	// 2. 伪3D光照计算 (优化版)
	// 光源拉远 (Z=2.0)，减少鼠标移动时的剧烈光影抖动
	vec3 light_pos = vec3(mouse_pos, 2.0); 
	vec3 view_pos = vec3(0.5, 0.5, 2.0);
	vec3 frag_pos = vec3(uv, 0.0);
	
	vec3 light_dir = normalize(light_pos - frag_pos);
	vec3 view_dir = normalize(view_pos - frag_pos);
	vec3 normal = get_normal(uv, width);
	
	float diff = max(dot(normal, light_dir), 0.0);
	vec3 halfway_dir = normalize(light_dir + view_dir);
	// 降低高光指数 (32 -> 16) 让光斑更散，不刺眼
	float spec = pow(max(dot(normal, halfway_dir), 0.0), 16.0);
	
	// 全息流光 (仅高阶卡牌，且变慢变淡)
	vec3 holographic = vec3(0.0);
	if (tier >= 3) {
		float holo_wave = sin(uv.x * 6.0 + uv.y * 6.0 + TIME * 1.0) * 0.5 + 0.5;
		holographic = vec3(0.5, 0.8, 1.0) * holo_wave * spec * 0.5; // 强度减半
	}
	
	// 3. 最终合成
	vec3 lighting = vec3(0.4); // 提高环境光，减少死黑
	if (border_mask > 0.5) {
		lighting += diff * 0.3; // 漫反射减弱
		lighting += spec * (0.3 + intensity * 0.3); // 镜面光大幅减弱 (0.8 -> 0.3)
	}
	
	vec3 final_color = albedo * lighting + holographic;
	
	final_color += albedo * intensity * 0.15;

	COLOR = vec4(final_color, 1.0);
}