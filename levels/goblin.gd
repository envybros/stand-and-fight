extends CharacterBody2D

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _process(_delta: float) -> void:
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		_animated_sprite.play("run")
	else:
		_animated_sprite.play("idle")

	velocity = Vector2(1.0, 1.0)
	move_and_slide()
