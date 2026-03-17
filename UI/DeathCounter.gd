extends Control

@onready var death_count_label = $HBoxContainer/DeathCountLabel

func _ready():
	update_death_count(GameManager.get_death_count())
	GameManager.death_count_changed.connect(_on_death_count_changed)


func _process(_delta):
	var root = get_tree().root
	
	# tìm node Loading trong toàn bộ tree
	var loading = root.find_child("Loading", true, false)
	
	if loading == null:
		return

	# 👇 check loading
	if loading.visible:
		get_parent().visible = false
	else:
		get_parent().visible = true


func _on_death_count_changed(new_count: int):
	update_death_count(new_count)


func update_death_count(count: int):
	death_count_label.text = "Deaths: " + str(count)
