extends Gun
class_name Uzi

@export var fire_rate: float = 10
var Bullets: PackedScene = load("res://guns/Bullet.tscn")

func _ready():
	$fire_period.wait_time = 1 / fire_rate
	
func spawn_bullets():
	var bullet = Bullets.instantiate()
	bullet.global_rotation = global_rotation
	bullet.global_position = $muzzle.global_position
	bullet.vel = $holster.global_position.direction_to(
		$muzzle.global_position
	) * bullet.speed
	return [bullet]
