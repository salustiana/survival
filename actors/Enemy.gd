extends CharacterBody2D
class_name Enemy

signal died(enemy)

@export var hp: int = 100
@export var speed: int = 250

func take_bullet(damage: int):
	if hp <= 0:		#avoid dying twice
		return
	hp -= damage
	if hp <= 0:
		emit_signal("died", self)
