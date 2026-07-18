extends CharacterBody3D

@export var speed: int = 20
@export var jumpForce: int = 120
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var mouseSensitivity: float = 0.003

@onready var camera_boom: Node3D = $"Camera Boom"

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouseSensitivity)
		camera_boom.rotate_x(-event.relative.y * mouseSensitivity)
		camera_boom.rotation.x = clamp(camera_boom.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func _physics_process(_delta):
	
	var input_dir = Input.get_vector("a", "d", "w", "s")
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	if Input.is_action_just_pressed("Space") and is_on_floor():
		velocity.y += jumpForce
	
	velocity.y -= gravity
	
	move_and_slide()
