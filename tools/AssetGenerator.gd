extends Node

func _ready():
	print("开始生成程序化纹理资源...")
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("assets/textures"):
		dir.make_dir_recursive("assets/textures")
	
	_generate_wood_table()
	_generate_metal_texture()
	_generate_frame_mask()
	
	print("所有纹理生成完毕。请在文件系统中检查 res://assets/textures/")
	get_tree().quit()

func _generate_wood_table():
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.02
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 5
	
	var img_size = Vector2i(1024, 1024)
	var diffuse_img = Image.create(img_size.x, img_size.y, false, Image.FORMAT_RGBA8)
	var normal_img = Image.create(img_size.x, img_size.y, false, Image.FORMAT_RGBA8)
	
	print("正在生成木纹桌面 (1024x1024)...")
	
	for y in range(img_size.y):
		for x in range(img_size.x):
			# 生成木纹逻辑
			var uv = Vector2(x, y) / Vector2(img_size)
			# 拉伸噪声模拟木纹
			var n = noise.get_noise_2d(x * 1.0, y * 8.0) 
			# 加入一些随机的深色条纹
			var grain = sin(y * 0.1 + n * 20.0) * 0.5 + 0.5
			grain = pow(grain, 4.0) * 0.5
			
			var base_col = Color(0.18, 0.12, 0.08) # 深棕色
			var light_col = Color(0.24, 0.16, 0.10) # 浅一点的棕色
			
			var final_col = base_col.lerp(light_col, n * 0.5 + 0.5)
			final_col = final_col.darkened(grain * 0.8)
			
			diffuse_img.set_pixel(x, y, final_col)
			
			# 生成法线 (简单的高度差转法线)
			var h1 = noise.get_noise_2d(x, y)
			var h2 = noise.get_noise_2d(x + 1.0, y)
			var h3 = noise.get_noise_2d(x, y + 1.0)
			var dx = (h1 - h2) * 5.0
			var dy = (h1 - h3) * 5.0
			var nz = 1.0
			var normal = Vector3(dx, dy, nz).normalized()
			# 将 -1..1 映射到 0..1
			normal = normal * 0.5 + Vector3(0.5, 0.5, 0.5)
			normal_img.set_pixel(x, y, Color(normal.x, normal.y, normal.z))
			
	diffuse_img.save_png("res://assets/textures/table_wood_diffuse.png")
	normal_img.save_png("res://assets/textures/table_wood_normal.png")

func _generate_metal_texture():
	var noise = FastNoiseLite.new()
	noise.frequency = 0.1
	noise.fractal_octaves = 3
	
	var img_size = Vector2i(512, 512)
	var img = Image.create(img_size.x, img_size.y, false, Image.FORMAT_RGBA8)
	
	print("正在生成金属质感 (512x512)...")
	
	for y in range(img_size.y):
		for x in range(img_size.x):
			var n = noise.get_noise_2d(x, y)
			# 更加细腻的噪点模拟磨砂金属
			var val = 0.5 + n * 0.1
			img.set_pixel(x, y, Color(val, val, val, 1.0))
			
	img.save_png("res://assets/textures/card_base_metal.png")

func _generate_frame_mask():
	var img_size = Vector2i(256, 256)
	var img = Image.create(img_size.x, img_size.y, false, Image.FORMAT_RGBA8)
	
	print("正在生成边框遮罩 (256x256)...")
	
	var border_w = 16.0
	for y in range(img_size.y):
		for x in range(img_size.x):
			var d_x = min(x, img_size.x - x)
			var d_y = min(y, img_size.y - y)
			var d = min(d_x, d_y)
			
			var alpha = 0.0
			if d < border_w:
				alpha = 1.0
			# 内发光/倒角过渡
			alpha *= smoothstep(0.0, 4.0, float(d))
			
			img.set_pixel(x, y, Color(1, 1, 1, alpha))
			
	img.save_png("res://assets/textures/card_frame_mask.png")
