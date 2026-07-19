extends Control

@export_file("*.tscn") var WORLD: String = "res://world.tscn" 

@onready var progress_bar: ProgressBar = $ColorRect/VBoxContainer/ProgressBar

var progress: Array = []
var loadStatus: int = 0

func _ready() -> void:
	ResourceLoader.load_threaded_request(WORLD)

func _process(delta: float) -> void:
	loadStatus = ResourceLoader.load_threaded_get_status(WORLD, progress)
	
	if progress.size() > 0:
		progress_bar.value = progress[0] * 100
	
	if loadStatus == ResourceLoader.THREAD_LOAD_LOADED:
		var newScene = ResourceLoader.load_threaded_get(WORLD)
		
		get_tree().change_scene_to_packed(newScene)
	elif loadStatus == ResourceLoader.THREAD_LOAD_FAILED:
		print("Error in loading Scene!")
