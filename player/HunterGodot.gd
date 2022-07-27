extends CharacterBody3D
@export_node_path(Node3D) var PlayerCharacterMesh: NodePath
@onready var player_mesh = get_node(PlayerCharacterMesh)

#Camera Vars
@export var mouse_sensitivity : float = 0.01
var camera_h = 0
var camera_v = 0
@export var camera_vertical_min = -90
@export var camera_vertical_max = 90
var acceleration_h = 5
var acceleration_v = 5
var joyview = Vector2()

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
# Mouse Input Controls
func _input(event):
	if event is InputEventMouseMotion:
		camera_h += -event.relative.x * mouse_sensitivity
		camera_v += -event.relative.y * mouse_sensitivity

# Joystick Input Controls
func _joystick_input():
	var input_dir = Input.get_vector("lookleft", "lookright", "lookup", "lookdown")
	camera_h += -input_dir.x * mouse_sensitivity * 4
	camera_v += input_dir.y * mouse_sensitivity * 4

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movement input from key input
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	# Moves where the camera is facing 
	#var h_rot = $pivot/Camera3D.global_transform.basis.get_euler().y
	#direction = direction.rotated(Vector3.UP, h_rot).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	#	rotation.y = lerp(rotation.y, h_rot, delta * acceleration_h )

	move_and_slide()
	_joystick_input()
# Joystick controls

## CAMERA rotations


	camera_v = clamp(camera_v,deg2rad(camera_vertical_min),deg2rad(camera_vertical_max))
	
	$pivot.rotation.y = lerp($pivot.rotation.y,camera_h,delta * acceleration_h)
	$pivot.rotation.x = lerp($pivot.rotation.x,camera_v,delta * acceleration_v)

