extends Node
class_name TextureGenerator

const TEX_PATH = "user://generated_textures/"

static func generate_if_needed():
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("generated_textures"):
		dir.make_dir("generated_textures")
	
	# 检查是否已生成，如果已存在则跳过
	if FileAccess.file_exists(TEX_PATH + "table_wood_diffuse.png") and \
	   FileAccess.file_exists(TEX_PATH + "table_wood_normal.png") and \
	   FileAccess.file_exists(TEX_PATH + "card_base_metal.png"):
		print("纹理资源已存在，跳过生成。")
		return

	print("正在生成程序化纹理资源...")
	
	_generate_wood_table()
	_generate_metal_texture()
	_generate_plate_texture()
	_generate_cutting_board()
	
	print("纹理生成完毕。路径: " + ProjectSettings.globalize_path(TEX_PATH))

static func _generate_plate_texture():
	var size = 256
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	var center = Vector2(size, size) * 0.5
	var radius = size * 0.45
	
	for y in range(size):
		for x in range(size):
			var d = center.distance_to(Vector2(x, y))
			var col = Color(0, 0, 0, 0)
			
			if d < radius:
				# 陶瓷白盘子
				var rim = smoothstep(radius - 10, radius, d)
				var height = cos(d / radius * 1.5) 
				var base = 0.9 + height * 0.1
				col = Color(base, base, base * 0.95, 0.9)
				
				# 盘沿阴影
				if d > radius * 0.85:
					col = col.darkened(0.15)
				
				# 简单的光泽
				if d < radius * 0.8:
					var spec = smoothstep(0.7, 0.8, sin(float(x+y)*0.05)) * 0.05
					col += Color(spec, spec, spec, 0)
			
			# 投影
			if d >= radius and d < radius + 8:
				var shadow_alpha = 1.0 - (d - radius) / 8.0
				col = Color(0, 0, 0, shadow_alpha * 0.4)
				
			img.set_pixel(x, y, col)
			
	img.save_png(TEX_PATH + "slot_plate.png")

static func _generate_cutting_board():
	var w = 256
	var h = 384
	var img = Image.create(w, h, false, Image.FORMAT_RGBA8)
	var noise = FastNoiseLite.new()
	noise.frequency = 0.05
	
	for y in range(h):
		for x in range(w):
			# 圆角矩形
			var dx = max(abs(x - w*0.5) - w*0.35, 0.0)
			var dy = max(abs(y - h*0.5) - h*0.42, 0.0)
			var dist = sqrt(dx*dx + dy*dy)
			
			if dist < 20.0:
				var wood_grain = noise.get_noise_2d(float(x), float(y)*4.0)
				var col = Color(0.45, 0.35, 0.25).lerp(Color(0.35, 0.25, 0.15), wood_grain * 0.5 + 0.5)
				
				# 边缘高光
				if dist > 16.0:
					col = col.darkened(0.4)
				elif dist > 14.0:
					col = col.lightened(0.2)
					
				img.set_pixel(x, y, col)
			elif dist < 28.0:
				# 阴影
				var alpha = 1.0 - (dist - 20.0) / 8.0
				img.set_pixel(x, y, Color(0,0,0, alpha * 0.5))
				
	img.save_png(TEX_PATH + "slot_board.png")

static func _generate_wood_table():
	var img_size = Vector2i(1024, 1024)
	var diffuse_img = Image.create(img_size.x, img_size.y, false, Image.FORMAT_RGBA8)
	var normal_img = Image.create(img_size.x, img_size.y, false, Image.FORMAT_RGBA8)
	
	var noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = 0.02
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 5
	
	for y in range(img_size.y):
		for x in range(img_size.x):
			var n = noise.get_noise_2d(float(x) * 1.0, float(y) * 8.0)
			var grain = sin(float(y) * 0.1 + n * 20.0) * 0.5 + 0.5
			grain = pow(grain, 4.0) * 0.5
			
			var base_col = Color(0.18, 0.12, 0.08)
			var light_col = Color(0.24, 0.16, 0.10)
			
			var final_col = base_col.lerp(light_col, n * 0.5 + 0.5)
			final_col = final_col.darkened(grain * 0.8)
			diffuse_img.set_pixel(x, y, final_col)
			
			# 生成法线
			var h1 = noise.get_noise_2d(float(x), float(y))
			var h2 = noise.get_noise_2d(float(x) + 1.0, float(y))
			var h3 = noise.get_noise_2d(float(x), float(y) + 1.0)
			var dx = (h1 - h2) * 8.0
			var dy = (h1 - h3) * 8.0
			var normal = Vector3(dx, dy, 1.0).normalized()
			normal = normal * 0.5 + Vector3(0.5, 0.5, 0.5)
			normal_img.set_pixel(x, y, Color(normal.x, normal.y, normal.z))
			
	diffuse_img.save_png(TEX_PATH + "table_wood_diffuse.png")
	normal_img.save_png(TEX_PATH + "table_wood_normal.png")

static func _generate_metal_texture():
	var img_size = Vector2i(512, 512)
	var img = Image.create(img_size.x, img_size.y, false, Image.FORMAT_RGBA8)
	
	var noise = FastNoiseLite.new()
	noise.frequency = 0.1
	noise.fractal_octaves = 3
	
	for y in range(img_size.y):
		for x in range(img_size.x):
			var n = noise.get_noise_2d(float(x), float(y))
			var val = 0.5 + n * 0.15
			img.set_pixel(x, y, Color(val, val, val, 1.0))
			
	img.save_png(TEX_PATH + "card_base_metal.png")

static func load_texture(filename: String) -> ImageTexture:
	var path = TEX_PATH + filename
	if not FileAccess.file_exists(path):
		return null
	var img = Image.load_from_file(path)
	return ImageTexture.create_from_image(img)
