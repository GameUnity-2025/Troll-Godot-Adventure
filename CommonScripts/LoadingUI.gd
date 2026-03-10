extends Node2D

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var label: Label = $Label
@onready var runner: AnimatedSprite2D = $AnimatedSprite2D

var progress_start_x: float
var progress_end_x: float

func _ready():
	await get_tree().process_frame
	progress_start_x = progress_bar.global_position.x
	progress_end_x = progress_bar.global_position.x + progress_bar.size.x
	runner.play("idle")
	hide()

func start():
	show()
	progress_bar.value = 0
	runner.play("run")

func update_progress(value: float):
	value = clamp(value, 0, 100)
	progress_bar.value = value
	
	# Di chuyển runner
	var percent = value / 100.0
	var target_x = lerp(progress_start_x, progress_end_x, percent)
	runner.global_position.x = lerp(
		runner.global_position.x,
		target_x,
		get_process_delta_time() * 8.0
	)
	
	# Giữ nguyên logic text như bạn đang có
	var percent_text = str(int(value)) + "%"
	if value < 30:
		label.text = "Đang kiểm tra dữ liệu... (" + percent_text + ")"
	elif value < 85:
		label.text = "Đang tải nội dung mới... (" + percent_text + ")"
	elif value < 100:
		label.text = "Đang hoàn tất... (" + percent_text + ")"
	else:
		label.text = "Hoàn tất!"

func finish():
	runner.play("idle")
	await get_tree().create_timer(0.3).timeout
	hide()
