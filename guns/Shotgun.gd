extends Gun
class_name Shotgun

@export var spread: float = PI/4
@export var pellets_per_shell: int = 5
@export var fire_rat: float = 3

var Bullets: PackedScene = load("res://guns/ShotgunPellet.tscn")

func _ready():
	$fire_period.wait_time = 1 / fire_rat

func spawn_bullets():
	var delta = spread / pellets_per_shell
	var bullets = []
	
	for i in range(pellets_per_shell):
		var bullet = Bullets.instantiate()
		bullet.global_rotation = global_rotation
		bullet.global_position = $muzzle.global_position
		bullet.vel = $holster.global_position.direction_to(
			$muzzle.global_position
		) * bullet.speed
		bullet.vel = bullet.vel.rotated(delta * i - spread / 2)
		bullets.append(bullet)
	return bullets
