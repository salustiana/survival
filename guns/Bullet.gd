extends Area2D
class_name Bullet

@export var speed: int = 2000
@export var damage: int = 50

var vel: Vector2

func _ready():
	if $expiration.connect("timeout", _on_expiration_timeout):
		printerr("connection failed")
	$expiration.one_shot = true
	$expiration.start()

func _on_expiration_timeout() -> void:
	queue_free()
