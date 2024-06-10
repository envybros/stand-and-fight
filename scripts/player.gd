extends CharacterBody2D

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer

var normal_speed := 100.0
var max_speed := normal_speed
var steering_factor := 10.0
var is_attacking := false

func _ready() -> void:
	timer.timeout.connect(attack_end)


func _physics_process(_delta: float) -> void:
	attack()
	
	if is_attacking:
		return
	
	movement(_delta)

func movement(_delta: float) -> void:
	# play movement anim
	var is_left := Input.is_action_pressed("move_left")
	var is_right := Input.is_action_pressed("move_right")
	var is_up := Input.is_action_pressed("move_up")
	var is_down := Input.is_action_pressed("move_down")
	
	if is_left or is_right or is_up or is_down:
		_animated_sprite.play("run")
	else:
		_animated_sprite.play("idle")
	
	# movement logic
	var direction = Vector2(0, 0)
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")
	
	if direction.length() > 1.0:
		direction = direction.normalized()
	
	var desired_velocity = max_speed * direction
	var steering_vector = desired_velocity - velocity
	
	velocity += steering_vector * steering_factor * _delta
	position += velocity * _delta
	
	if !is_zero_approx(velocity.x):
		_animated_sprite.flip_h = velocity.x < 0
		rotation = 0


func attack() -> void:
	# attack anim
	var is_attack := Input.is_action_just_pressed("attack00")
	
	if is_attack:
		is_attacking = true
		timer.start(0.5)
		_animated_sprite.play("attack")


func attack_end() -> void:
	is_attacking = false
