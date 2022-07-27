extends Spatial

# Allows to select the player mesh from the inspector
export (NodePath) var PlayerCharacterMesh

var camrot_h = 0
var camrot_v = 0
export var cam_v_max = 75 # -75 recommended
export var cam_v_min = -55 # -55 recommended
export var joystick_sensitivity = 20
var h_sensitivity = .1
var v_sensitivity = .1
var rot_speed_multiplier = .15 #reduce this to make the rotation radius larger
var h_acceleration = 10
var v_acceleration = 10
var joyview = Vector2()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$h/v/Camera.add_exception(get_parent())
	
func _input(event):
	if event is InputEventMouseMotion:
		$control_stay_delay.start()
		camrot_h += -event.relative.x * h_sensitivity
		camrot_v += event.relative.y * v_sensitivity
		
func _joystick_input():
	if (Input.is_action_pressed("lookup") ||  Input.is_action_pressed("lookdown") ||  Input.is_action_pressed("lookleft") ||  Input.is_action_pressed("lookright")):
		$control_stay_delay.start()
		joyview.x = Input.get_action_strength("lookleft") - Input.get_action_strength("lookright")
		joyview.y = Input.get_action_strength("lookup") - Input.get_action_strength("lookdown")
		camrot_h += joyview.x * joystick_sensitivity * h_sensitivity
		camrot_v += joyview.y * joystick_sensitivity * v_sensitivity 
		#$h.rotation_degrees.y = lerp($h.rotation_degrees.y, camrot_h, delta * h_acceleration)
		
func _physics_process(delta):
	# JoyPad Controls
	_joystick_input()
		
	camrot_v = clamp(camrot_v, cam_v_min, cam_v_max)
	
	var mesh_front = get_node(PlayerCharacterMesh).global_transform.basis.z
	var auto_rotate_speed =  (PI - mesh_front.angle_to($h.global_transform.basis.z)) * get_parent().horizontal_velocity.length() * rot_speed_multiplier
	
	if $control_stay_delay.is_stopped():
		#FOLLOW CAMERA
		$h.rotation.y = lerp_angle($h.rotation.y, get_node(PlayerCharacterMesh).global_transform.basis.get_euler().y, delta * auto_rotate_speed)
		camrot_h = $h.rotation_degrees.y
	else:
		#MOUSE CAMERA
		$h.rotation_degrees.y = lerp($h.rotation_degrees.y, camrot_h, delta * h_acceleration)
	
	$h/v.rotation_degrees.x = lerp($h/v.rotation_degrees.x, camrot_v, delta * v_acceleration)
	
