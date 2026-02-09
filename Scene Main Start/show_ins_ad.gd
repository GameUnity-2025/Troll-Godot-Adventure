extends TouchScreenButton

# Animation tweens
var pulse_tween: Tween
var glow_tween: Tween
var wiggle_tween: Tween

# Original values
var original_scale: Vector2
var original_rotation: float

func _ready():
	# Store original values
	original_scale = scale
	original_rotation = rotation
	
	# Connect pressed signal for click effect
	pressed.connect(_on_pressed)
	
	# Start animations when button is visible
	if visible:
		start_animations()
	
	# Connect visibility changed signal
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed():
	if visible:
		start_animations()
	else:
		stop_animations()

func start_animations():
	# Start all animation effects
	start_pulse_animation()
	start_glow_animation()
	start_wiggle_animation()

func stop_animations():
	# Clean up tweens
	if pulse_tween:
		pulse_tween.kill()
	if glow_tween:
		glow_tween.kill()
	if wiggle_tween:
		wiggle_tween.kill()

func start_pulse_animation():
	"""Hiệu ứng phóng to/thu nhỏ liên tục"""
	if pulse_tween:
		pulse_tween.kill()
	
	pulse_tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.set_trans(Tween.TRANS_SINE)
	pulse_tween.set_ease(Tween.EASE_IN_OUT)
	
	# Phóng to 15%
	pulse_tween.tween_property(self, "scale", original_scale * 1.15, 0.8)
	# Thu nhỏ về 95%
	pulse_tween.tween_property(self, "scale", original_scale * 0.95, 0.8)
	# Về lại kích thước bình thường
	pulse_tween.tween_property(self, "scale", original_scale, 0.8)

func start_glow_animation():
	"""Hiệu ứng lấp lánh/phát sáng"""
	if glow_tween:
		glow_tween.kill()
	
	glow_tween = create_tween()
	glow_tween.set_loops()
	glow_tween.set_trans(Tween.TRANS_SINE)
	glow_tween.set_ease(Tween.EASE_IN_OUT)
	
	# Sáng lên (màu trắng nhạt)
	glow_tween.tween_property(self, "modulate", Color(1.3, 1.3, 1.0, 1.0), 0.6)
	# Về màu bình thường
	glow_tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.6)
	# Sáng lên lần 2 (màu vàng nhạt)
	glow_tween.tween_property(self, "modulate", Color(1.2, 1.2, 0.8, 1.0), 0.5)
	# Về màu bình thường
	glow_tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5)

func start_wiggle_animation():
	"""Hiệu ứng lắc nhẹ để thu hút sự chú ý"""
	if wiggle_tween:
		wiggle_tween.kill()
	
	wiggle_tween = create_tween()
	wiggle_tween.set_loops()
	wiggle_tween.set_trans(Tween.TRANS_ELASTIC)
	wiggle_tween.set_ease(Tween.EASE_IN_OUT)
	
	# Xoay sang phải 5 độ
	wiggle_tween.tween_property(self, "rotation_degrees", original_rotation + 5, 0.4)
	# Xoay sang trái 5 độ
	wiggle_tween.tween_property(self, "rotation_degrees", original_rotation - 5, 0.4)
	# Về vị trí ban đầu
	wiggle_tween.tween_property(self, "rotation_degrees", original_rotation, 0.4)
	# Dừng một chút
	wiggle_tween.tween_interval(1.0)

func _on_pressed():
	"""Hiệu ứng khi người chơi bấm vào button"""
	# Tạm dừng animations
	stop_animations()
	
	# Hiệu ứng click: thu nhỏ và phóng to nhanh
	var click_tween = create_tween()
	click_tween.set_trans(Tween.TRANS_BACK)
	click_tween.set_ease(Tween.EASE_IN_OUT)
	
	click_tween.tween_property(self, "scale", original_scale * 0.85, 0.1)
	click_tween.tween_property(self, "scale", original_scale * 1.1, 0.15)
	click_tween.tween_property(self, "scale", original_scale, 0.1)
	
	# Restart animations sau khi click
	await click_tween.finished
	if visible:
		start_animations()
