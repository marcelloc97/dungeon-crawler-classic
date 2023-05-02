class_name smooth_mouse_look extends Node

@export var head_rotation_limit := [-90.0, 90.0] # index 0 is min / index 1 is max
@export_range(0.05, 1) var sensitivity := 0.1
@export_range(1.0, 50.0) var smoothness := 20.0

var rotation_velocity: Vector2
var camera_input: Vector2

@export var head: Node3D
@export var character: FPSCharacter


func _ready():
	assert(head and character != null)

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	var is_mouse_motion = event is InputEventMouseMotion
	var is_mouse_captured = Input.mouse_mode == Input.MOUSE_MODE_CAPTURED

	if is_mouse_motion and is_mouse_captured:
		camera_input = event.relative

	if event is InputEventMouseButton:
		if event.is_action_pressed('attack'):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if event is InputEventKey:
		if event.is_action_pressed('ui_cancel'):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta):
	fps_look(delta)


func fps_look(delta):
	rotation_velocity = rotation_velocity.lerp(camera_input * sensitivity, delta * smoothness)

	# rotate the head on x axis
	head.rotate_x(-deg_to_rad(rotation_velocity.y))

	# rotate the body on y axis
	character.rotate_y(-deg_to_rad(rotation_velocity.x))

	# limit the vertical head rotation to given rotation from degrees to radians
	head.rotation.x = clamp(
		head.rotation.x,
		deg_to_rad(head_rotation_limit[0]),
		deg_to_rad(head_rotation_limit[1])
	)

	camera_input = Vector2.ZERO
