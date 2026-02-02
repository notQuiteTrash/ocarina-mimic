extends SpringArm3D

@onready var camera : Camera3D = $Camera3D
# The above is "Syntactic Sugar", and it could also be written as:
# @onready var camera : Camera3D = get_node("Camera3D")
@onready var player: Node3D = get_parent()

@export var turn_rate := 250.0
@export var mouse_sens := .30
var mouse_input : Vector2 = Vector2()
var cam_rig_height : float = position.y

# Called when the node enters the scene tree for the first time.
# This overrides the camera with the springarm z position
func _ready() -> void:
	spring_length = camera.position.z
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Called every frame. 'delta' is the elapsed time since the previous frame.
# Camera controls for controller
func _process(delta: float) -> void:
	var look_input := Input.get_vector("view_right", "view_left", "view_down", "view_up")
	look_input = turn_rate * look_input * delta
	look_input += mouse_input
	mouse_input = Vector2()
	# rotation.degrees.x = look_input.y because in the line above, "up" and "down" is in the "y" argument for the vector
	# Input.get_vector("x", "y") -> "view_left", "view_right" is the "x" value and "view_up", "view_down" is the "y" value
	rotation_degrees.x += look_input.y
	rotation_degrees.y += look_input.x
	rotation_degrees.x = clampf(rotation_degrees.x, -80, 45)

# Camera controls for the mouse
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_input = -event.relative * mouse_sens
	elif event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Makes the camera follow the player
func _physics_process(delta: float) -> void:
	position = player.position + Vector3(0, cam_rig_height, 0)
