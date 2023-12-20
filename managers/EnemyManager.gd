extends Node2D

signal enemy_killed

@export var radius: int = 1000
@export var base_spawn_period: float = 0.9
@export var spawn_period_mult: float = 0.99
@export var min_spawn_period: float = 0.25
@export var Enemies: PackedScene = load("res://actors/Enemy.tscn")

var player: Player
var HUD

func _ready():
	if $spawn_period.connect("timeout", _on_spawn_period_timeout):
		printerr("connection failed")
	$spawn_period.wait_time = base_spawn_period

func _physics_process(delta):
	for enemy in get_children():
		if enemy is Enemy:
			enemy.global_position += enemy.global_position.direction_to(
				player.global_position
			) * enemy.speed * delta

func _on_enemy_died(enemy):
	enemy.queue_free()
	if $spawn_period.wait_time > min_spawn_period:
		$spawn_period.wait_time *= spawn_period_mult
		HUD.get_node("spawn_rate").value = (
			min_spawn_period/$spawn_period.wait_time
		) * 100
	elif $spawn_period.wait_time < min_spawn_period:
		$spawn_period.wait_time = min_spawn_period
	emit_signal("enemy_killed")

func _on_spawn_period_timeout():
	var rand_dir = Vector2.UP.rotated(randi())
	var enemy = Enemies.instantiate()
	if enemy.connect("died", _on_enemy_died):
		printerr("connection failed")
	enemy.global_position = player.global_position + radius * rand_dir
	add_child(enemy)

func free_all() -> void:
	for enemy in get_children():
		if enemy is Enemy:
			enemy.queue_free()

func start() -> void:
	$spawn_period.wait_time = base_spawn_period
	$spawn_period.start()
	
	HUD.get_node("spawn_rate").value = (
		min_spawn_period/$spawn_period.wait_time
	) * 100

func stop() -> void:
	$spawn_period.stop()
	free_all()
