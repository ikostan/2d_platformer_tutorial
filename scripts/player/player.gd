class_name Player extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var speed: float = 200.0
@export var air_speed: float = 150.0
@export var air_acceleration: float = 0.1
@export var jump_force: float = -400.0
@export var gravity: float = 980.0

var direction: float

func _process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	direction = Input.get_axis("left", "right")


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		handle_air_movement(delta)
	else:
		handle_ground_movement(delta)
		
	update_animation()
	move_and_slide()


func handle_air_movement(delta) -> void:
	if direction:
		# flip animation direction left/right
		sprite_2d.flip_h = direction < 0


func handle_ground_movement(delta: float) -> void:
	if direction:
		velocity.x = (direction * speed) + delta
		# flip animation direction left/right
		sprite_2d.flip_h = direction < 0
	else:
		# No direction, stop player slowly
		velocity.x = move_toward(velocity.x, 0, speed)
	
	
func update_animation() -> void:
	if not is_on_floor() and velocity.y < 0:
		animation_player.play("jump")
	elif not is_on_floor():
		animation_player.play("fall")
	elif is_on_floor() and velocity.x:
		animation_player.play("run")
	elif is_on_floor():
		animation_player.play("idle")
		
