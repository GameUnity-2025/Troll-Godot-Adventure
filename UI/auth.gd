extends Control

@onready var username_input = $Panel/VBoxContainer/UsernameInput
@onready var password_input = $Panel/VBoxContainer/PasswordInput
@onready var main_btn = $Panel/VBoxContainer/MainButton
@onready var switch_btn = $Panel/VBoxContainer/SwitchButton
@onready var status = $Panel/VBoxContainer/StatusLabel
@onready var title = $Panel/VBoxContainer/Title
@onready var confirm_password_input = $Panel/VBoxContainer/ConfirmPasswordInput

var is_login_mode = true

func _ready():
	# Truy cập trực tiếp vào Singleton qua root
	var dc_ui = get_node_or_null("/root/DeathCounterUI")
	if dc_ui:
		dc_ui.visible = false
		print("🔒 Đã ẩn DeathCounterUI (CanvasLayer Singleton)")
	
	update_ui()
	

func update_ui():
	if is_login_mode:
		title.text = "LOGIN"
		main_btn.text = "Login"
		switch_btn.text = "Don't have account? Register"
		confirm_password_input.visible = false
		
	else:
		title.text = "REGISTER"
		main_btn.text = "Register"
		switch_btn.text = "Already have account? Login"
		confirm_password_input.visible = true
	username_input.text = ""
	password_input.text = ""
	confirm_password_input.text = ""

	status.text = ""

func _on_main_button_pressed(): # Sửa lại tên signal cho đúng chuẩn Godot 4 nếu cần
	var user_text = username_input.text.strip_edges()
	var pass_text = password_input.text.strip_edges()

	var confirm_text = confirm_password_input.text.strip_edges()

	if user_text == "" or pass_text == "":
		status.text = "❌ Enter username & password"
		return

	if !is_login_mode:
		if confirm_text == "":
			status.text = "❌ Confirm your password"
			return
		
		if pass_text != confirm_text:
			status.text = "❌ Passwords do not match"
			return
	if is_login_mode:
		do_login(user_text, pass_text)
	else:
		do_register(user_text, pass_text)

func _on_switch_button_pressed():
	is_login_mode = !is_login_mode
	update_ui()

func do_login(user, password):
	status.text = "⏳ Logging in..."

	APIManager.login(user, password, func(success, msg):
		if success:
			status.text = "✅ Login success"
			APIManager.get_player_data()
			# 2. CHUYỂN HƯỚNG VỀ MAIN.TSCN
			# Chúng ta chuyển về main.tscn để script main.gd chạy quy trình 
			# kiểm tra update server và tải PCK (DLC)
			await get_tree().create_timer(0.5).timeout
			
			var main_path = "res://Scene Main Start/main.tscn"
			if ResourceLoader.exists(main_path):
				get_tree().change_scene_to_file(main_path)
			else:
				status.text = "❌ Error: main.tscn not found!"
		else:
			status.text = "❌ " + msg
	)

func do_register(user, password):
	status.text = "⏳ Registering..."

	APIManager.register(user, password, func(success, msg):
		if success:
			status.text = "✅ Registered! Logging in..."
			await get_tree().create_timer(0.5).timeout
			# 🔥 AUTO LOGIN NGAY
			do_login(user, password)

		else:
			status.text = "❌ " + msg
	)
