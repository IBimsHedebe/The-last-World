extends Control

@export_file("*.tscn") var WORLD: String = "res://world.tscn" 

@onready var progress_bar: ProgressBar = $ColorRect/VBoxContainer/ProgressBar
@onready var label: Label = $ColorRect/VBoxContainer/Label

var progress: Array = []
var worldInstance: Node = null
var isGenerating: bool = false

func _ready() -> void:
	label.text = "Lade Spieldateien ..."
	ResourceLoader.load_threaded_request(WORLD)

func _process(delta: float) -> void:
	if isGenerating:
		return
	
	
	var loadStatus = ResourceLoader.load_threaded_get_status(WORLD, progress)
	
	if progress.size() > 0:
		progress_bar.value = progress[0] * 50.0
	
	if loadStatus == ResourceLoader.THREAD_LOAD_LOADED and not isGenerating:
		isGenerating = true
		label.text = "Generating World and Biomes ..."
		
		var newScene = ResourceLoader.load_threaded_get(WORLD)
		worldInstance = newScene.instantiate()
		
		var meshMode = worldInstance.get_node("MeshInstance3D")
		
		meshMode.generationProgress.connect(_on_world_generation_progress)
		meshMode.generationFinished.connect(_on_world_generation_finished)
		
		get_tree().root.add_child(worldInstance)
		worldInstance.visible = false

func _on_world_generation_progress(percent: float):
	progress_bar.value = 50.0 + (percent * 0.5)

func _on_world_generation_finished():
	worldInstance.visible = true
	queue_free()
