extends CharacterBody3D

var speed = 20
var jumpForce = 40
var gravity = 3

func _ready() -> void:
	pass

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
