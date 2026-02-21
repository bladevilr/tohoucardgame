shader_type canvas_item;

uniform vec4 player_color : source_color = vec4(0.2, 0.6, 1.0, 0.3);
uniform vec4 opponent_color : source_color = vec4(1.0, 0.3, 0.3, 0.3);
uniform float balance : hint_range(0.0, 1.0) = 0.5; // 0.5 = 势均力敌, 1.0 = 玩家完胜
uniform float intensity : hint_range(0.0, 1.0) = 0.0; // 卖相总强度

uniform sampler2D noise_tex : repeat_enable;

void fragment() {
	vec2 uv = UV;
	
	// 流动的背景噪点，模拟“气场”
	float noise1 = texture(noise_tex, uv * 0.5 + vec2(TIME * 0.05, TIME * 0.02)).r;
	float noise2 = texture(noise_tex, uv * 0.8 - vec2(TIME * 0.03, TIME * 0.04)).r;
	float cloud = (noise1 + noise2) * 0.5;
	
	// 计算交界线 (带有噪点扰动，不是直线)
	float border = balance + (cloud - 0.5) * 0.3;
	float mask = smoothstep(border - 0.05, border + 0.05, uv.x);
	
	// 混合颜色
	vec4 col = mix(player_color, opponent_color, mask);
	
	// 动态光晕 (呼吸感)
	float pulse = 0.8 + 0.2 * sin(TIME * 2.0);
	col.rgb *= (0.8 + cloud * 0.4) * pulse;
	
	// 强度控制 (卖相越高，背景越亮)
	col.a *= 0.3 + intensity * 0.5;
	
	// 边缘暗角保留，聚焦视线
	float dist = distance(uv, vec2(0.5));
	col.rgb *= 1.0 - smoothstep(0.4, 1.0, dist);
	
	COLOR = col;
}
