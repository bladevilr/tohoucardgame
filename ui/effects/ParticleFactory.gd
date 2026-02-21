extends Node

func _spawn_one_shot(parent: Node, position: Vector2, amount: int, color: Color, spread: float, speed_min: float, speed_max: float, lifetime: float) -> GPUParticles2D:
	if parent == null:
		return null
	var particles = GPUParticles2D.new()
	particles.position = position
	particles.amount = amount
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.lifetime = lifetime
	particles.emitting = false

	var mat = ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = spread
	mat.initial_velocity_min = speed_min
	mat.initial_velocity_max = speed_max
	mat.gravity = Vector3(0, 220, 0)
	mat.scale_min = 0.7
	mat.scale_max = 1.2
	mat.color = color
	particles.process_material = mat

	parent.add_child(particles)
	particles.emitting = true
	particles.finished.connect(func(): particles.queue_free())
	return particles

func spawn_coin_burst(parent: Node, position: Vector2) -> GPUParticles2D:
	return _spawn_one_shot(parent, position, 18, Color(1.0, 0.85, 0.25, 1.0), 65.0, 130.0, 230.0, 0.55)

func spawn_star_burst(parent: Node, position: Vector2, color: Color = Color(1.0, 0.95, 0.65, 1.0)) -> GPUParticles2D:
	return _spawn_one_shot(parent, position, 24, color, 90.0, 90.0, 210.0, 0.6)

func spawn_score_burst(parent: Node, position: Vector2, high_score: bool = false) -> GPUParticles2D:
	var amount = 32 if high_score else 14
	var color = Color(1.0, 0.82, 0.2, 1.0) if high_score else Color(0.45, 0.82, 1.0, 1.0)
	var speed_max = 280.0 if high_score else 210.0
	return _spawn_one_shot(parent, position, amount, color, 75.0, 110.0, speed_max, 0.7)

func spawn_flame(parent: Node, position: Vector2) -> GPUParticles2D:
	if parent == null:
		return null
	var particles = GPUParticles2D.new()
	particles.position = position
	particles.amount = 18
	particles.one_shot = false
	particles.lifetime = 0.9
	particles.preprocess = 0.2
	particles.emitting = true

	var mat = ParticleProcessMaterial.new()
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 25.0
	mat.initial_velocity_min = 20.0
	mat.initial_velocity_max = 60.0
	mat.gravity = Vector3(0, -40, 0)
	mat.scale_min = 0.6
	mat.scale_max = 1.0
	mat.color = Color(1.0, 0.45, 0.15, 0.85)
	particles.process_material = mat
	parent.add_child(particles)
	return particles
