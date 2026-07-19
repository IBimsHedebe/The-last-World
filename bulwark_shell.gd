extends CharacterBody3D

enum State { IDLE, CHASE, CHARGING, RECOVERY }
var currentState: State = State.IDLE

@export var speed: int = 3
@export var chargedSpeed: int = 12
@export var health: int = 3

@onready var player: Node3D = %Player
@onready var recovery_timer: Timer = $RecoveryTimer
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

var chargeDirection: Vector3 = Vector3.ZERO
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	currentState = State.CHASE

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	match currentState:
		State.CHASE:
			_move_towards_player()
		State.CHARGING:
			_execute_charging(delta)
		State.RECOVERY:
			velocity.x = 0
			velocity.z = 0
	
	move_and_slide()

func _move_towards_player():
	if not player: return
	
	var direction = (player.global_position - global_position)
	direction.y = 0
	direction = direction.normalized()
	
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	
	if velocity.length() > 0.1:
		var targetLook = global_position + direction
		look_at(targetLook, Vector3.UP)
	
	if global_position.distance_to(player.global_position) < 8.0 and randf():
		_start_charge(direction)

func _start_charge(direction: Vector3):
	currentState = State.CHARGING
	chargeDirection = direction
	
	var material = mesh_instance_3d.get_active_material(0)
	if material == StandardMaterial3D:
		material.albedo_color = Color.RED
	
	await get_tree().create_timer(1.5).timeout
	if currentState == State.CHARGING:
		_enter_recovery()

func _execute_charging(_delta: float):
	velocity.x = chargeDirection.x * chargedSpeed
	velocity.z = chargeDirection.z * chargedSpeed
	
	if is_on_wall():
		_enter_recovery()

func _enter_recovery():
	currentState = State.RECOVERY
	
	var material = mesh_instance_3d.get_active_material(0)
	if material == StandardMaterial3D:
		material.albedo_color = Color.WHITE
	
	mesh_instance_3d.rotation_degrees.z = 45
	recovery_timer.start(3.0)

func _on_recovery_timer_timeout():
	mesh_instance_3d.rotation_degrees.z = 0
	currentState = State.CHASE


func _on_weak_spot_area_entered(hitbox: Area3D) -> void:
	if hitbox.is_in_group("PlayerAttack"):
		_take_damage(1)

func _hit_armor_front():
	# add block particle
	print("Blocked! Armor too thick.")

func _take_damage(amount: int):
	# add damage particle
	health -= amount
	print("Direct hit to the weakspot! HP left: ", health)
	
	if health <= 0:
		_die()

func _die():
	# add death particle and death animation
	queue_free()
