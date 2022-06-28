extends KinematicBody



# Allows to pick your animation tree from the inspector
export (NodePath) var PlayerAnimationTree 
export onready var animation_tree = get_node(PlayerAnimationTree)
onready var playback = animation_tree.get("parameters/playback");

# Allows to pick your chracter's mesh from the inspector
export (NodePath) var PlayerCharacterMesh
export onready var player_mesh = get_node(PlayerCharacterMesh)

# Gamplay mechanics and Inspector tweakables
export var gravity = 9.8
export var jump_force = 9
export var walk_speed = 2
export var run_speed = 5
export var dash_power = 12 # Controls roll and big attack speed boosts
# Animation node names
var roll_node_name = "Roll"
var idle_node_name = "Idle"
var run_node_name = "Run"
var jump_node_name = "Jump"
var attack1_node_name = "Attack1"
var attack2_node_name = "Attack2"
var bigattack_node_name = "BigAttack"

var direction = Vector3()
var horizontal_velocity = Vector3()
var aim_turn = float()
var movement = Vector3()
var vertical_velocity = Vector3()
var movement_speed = int()
var angular_acceleration = int()
var is_attacking = bool()
var is_rolling = bool()


func _ready(): # Camera based Rotation
	direction = Vector3.BACK.rotated(Vector3.UP, $Camroot/h.global_transform.basis.get_euler().y)

func _input(event): # All major mouse and button input events
	if event is InputEventMouseMotion:
		aim_turn = -event.relative.x * 0.015 # animates player with mouse movement while aiming 
	
	if event.is_action_pressed("aim"): # Aim button triggers a strafe walk and camera mechanic
		direction = $Camroot/h.global_transform.basis.z

## Dodge button input with dash and interruption to basic actions
	if !roll_node_name in playback.get_current_node() and !jump_node_name in playback.get_current_node() and !bigattack_node_name in playback.get_current_node():
		if event.is_action_pressed("roll"):
			playback.start(roll_node_name) #"start" not "travel" to speedy teleport to the roll!
			horizontal_velocity = direction * dash_power

# Attack button input: with combos and sprint attack examples
	if (is_rolling != true) and is_on_floor():
		# Attack 1
		if (is_attacking == false) and event.is_action_pressed("attack"):
			playback.travel(attack1_node_name)
		# Attack 2 if Attack button pressed again.
		if attack1_node_name in playback.get_current_node() and event.is_action_pressed("attack"): #Combo Attack 1 into 2
			playback.travel(attack2_node_name)
		if attack2_node_name in playback.get_current_node() and event.is_action_pressed("attack"): #Combo Attack 2 into... add more attacks?!
			pass
		# BigAttack if Attack button pressed while sprinting
		if run_node_name in playback.get_current_node() and event.is_action_pressed("attack"): # Big Attack if sprinting, adds a dash
			horizontal_velocity = direction * dash_power
			playback.travel(bigattack_node_name)

#	Final attack lines, prevent node travel during final attacks, stopping attack1 from happening immediately after other attack combos finish.
		if (bigattack_node_name in playback.get_current_node()) or (attack2_node_name in playback.get_current_node()) and event.is_action_pressed("attack"): 
			playback.travel(idle_node_name)

	
func _physics_process(delta):
	
	var is_attacking = false
	var is_walking = false
	var is_running = false
	var is_rolling = false
	var on_floor = is_on_floor() # AKA is jumping/falling/landing
	var movement_speed = 0
	var angular_acceleration = 10
	var acceleration = 15

	var h_rot = $Camroot/h.global_transform.basis.get_euler().y

	# Gravity mechanics and prevent slope-sliding
	if not is_on_floor(): vertical_velocity += Vector3.DOWN * gravity * 2 * delta
	else: vertical_velocity = -get_floor_normal() * gravity / 3
	
	# Defining attack state: Add more attacks here if you like
	if (attack1_node_name in playback.get_current_node()) or (attack2_node_name in playback.get_current_node()) or (bigattack_node_name in playback.get_current_node()): 
		is_attacking = true

# Giving BigAttack some Slide
	if bigattack_node_name in playback.get_current_node(): acceleration = 3

	# Defining Roll state and limiting movment during rolls
	if roll_node_name in playback.get_current_node(): 
		is_rolling = true
		acceleration = 2
		angular_acceleration = 2
	
	# Jump input and Mechanics
	if Input.is_action_just_pressed("jump") and ((is_attacking != true) and (is_rolling != true)) and is_on_floor():
		vertical_velocity = Vector3.UP * jump_force
		
	# Movement input, state and mechanics. *Note: movement stops if attacking
	if (Input.is_action_pressed("forward") ||  Input.is_action_pressed("backward") ||  Input.is_action_pressed("left") ||  Input.is_action_pressed("right")):
		direction = Vector3(Input.get_action_strength("left") - Input.get_action_strength("right"),
					0,
					Input.get_action_strength("forward") - Input.get_action_strength("backward"))
		direction = direction.rotated(Vector3.UP, h_rot).normalized()
		is_walking = true
	# Sprint input, state and speed
		if Input.is_action_pressed("sprint"): 
			movement_speed = run_speed
			is_running = true
		else: # Walk State and speed
			movement_speed = walk_speed

	if Input.is_action_pressed("aim"):  # Aim/Strafe input and  mechanics
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, $Camroot/h.rotation.y, delta * angular_acceleration)

	else: # Normal turn movement mechanics
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(direction.x, direction.z) - rotation.y, delta * angular_acceleration)
	
	# Movment mechanics with limitations during rolls/attacks
	if ((is_attacking == true) or (is_rolling == true)): 
		horizontal_velocity = horizontal_velocity.linear_interpolate(direction.normalized() * .01 , acceleration * delta)
	else: # Movement mechanics without limitations 
		horizontal_velocity = horizontal_velocity.linear_interpolate(direction.normalized() * movement_speed, acceleration * delta)
	
	# The Sauce. Movement, gravity and velocity in a perfect dance.
	movement.z = horizontal_velocity.z + vertical_velocity.z
	movement.x = horizontal_velocity.x + vertical_velocity.x
	movement.y = vertical_velocity.y
	move_and_slide(movement, Vector3.UP)

	# ========= State machine controls =========
	# The booleans of the on_floor, is_walking etc, trigger the 
	# advanced conditions of the AnimationTree, controlling animation paths
	
	# on_floor manages jumps and falls
	animation_tree["parameters/conditions/IsOnFloor"] = on_floor
	animation_tree["parameters/conditions/IsInAir"] = !on_floor
	# Moving and running respectively
	animation_tree["parameters/conditions/IsWalking"] = is_walking
	animation_tree["parameters/conditions/IsNotWalking"] = !is_walking
	animation_tree["parameters/conditions/IsRunning"] = is_running
	animation_tree["parameters/conditions/IsNotRunning"] = !is_running
	# Attacks and roll don't use these boolean conditions, instead
	# they use "travel" or "start" to one-shot their animations.
	
	
