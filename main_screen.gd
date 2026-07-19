extends Control
@export_file("*.tscn") var loadingScreen: String = "res://load-screen.tscn"

@onready var startButton: Button = $MarginContainer/VBoxContainer/StartButton
@onready var exitButton: Button = $MarginContainer/VBoxContainer/ExitButton

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	startButton.pressed.connect(_on_start_button_pressed)
	exitButton.pressed.connect(_on_exit_button_pressed)


func _on_start_button_pressed():
	get_tree().change_scene_to_file(loadingScreen)

func _on_exit_button_pressed():
	get_tree().quit()
