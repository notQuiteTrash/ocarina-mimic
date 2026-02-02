extends CharacterBody3D 
@onready var anim_player: AnimationPlayer = $Mesh/AnimationPlayer

@export var speed : float = 5.0
# You type the above line like this as well: @export var speed:= 5.0
# This is called Type Inference
const JUMP_VELOCITY = 4.5
@onready var camera : Node3D = $CameraRig/Camera3D

func get_boosted_speed(boost_mult:float) -> float:
	return speed * boost_mult

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		

	# Handle jump.
	if Input.is_action_just_pressed("move_jump") and is_on_floor():  
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (camera.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	direction = Vector3(direction.x, 0, direction.z).normalized() * input_dir.length()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
	turn_to(direction)

	var current_speed := velocity.length()
	const RUN_SPEED := 4.0
	const BLEND_SPEED := 0.2
	
	if current_speed > RUN_SPEED :
		anim_player.play("freehand_run", BLEND_SPEED) 
	elif current_speed > 0.0 :
		anim_player.play("freehand_walk", BLEND_SPEED, lerp(0.5, 1.75, current_speed / RUN_SPEED))
	else: 
		anim_player.play("freehand_idle")
	
		
func turn_to(direction: Vector3) -> void:
	if direction.length() > 0 :
		var yaw := atan2(-direction.x,-direction.z)
		yaw = lerp_angle(rotation.y, yaw, .18)
		rotation.y = yaw
