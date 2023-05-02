class_name FPSCharacter extends CharacterBody3D

const RUNNING_ANGLE = 1.2
const WALKING_ANGLE = 1.0
const IDLE_ANGLE = 0.85

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var sprint_speed := 4.0
@export var speed := 2.0
@export var jump_force := 4.5

var is_sprinting = false
var is_crouching = false

@onready var body := $Collider


func _physics_process(delta):
	set_angle_based_on_action()
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Sprint, Jump and Crouch.
	if is_on_floor():
		is_sprinting = Input.is_action_pressed('sprint')
		
		if Input.is_action_pressed('jump') and not is_crouching:
			velocity.y = jump_force
		
		if Input.is_action_just_pressed('crouch'):
			is_crouching = not is_crouching
		
		manage_crouch(delta)

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * get_current_speed()
		velocity.z = direction.z * get_current_speed()
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()


func set_angle_based_on_action():
	if is_sprinting:
		floor_max_angle = RUNNING_ANGLE
	elif not is_sprinting:
		floor_max_angle = WALKING_ANGLE
	else:
		floor_max_angle = IDLE_ANGLE

func get_current_speed() -> float:
	var current_speed = (speed if not is_sprinting else sprint_speed)
	return current_speed if not is_crouching else current_speed / 2

func manage_crouch(delta):
	var height = 1.0 if is_crouching else 1.5
	body.shape.height = lerp(body.shape.height, height, 0.2)
