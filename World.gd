extends Node

@onready var viewport_size: Vector2 = get_viewport().size

@onready var ShotgunClass = load("res://guns/Shotgun.tscn")
@onready var UziClass = load("res://guns/Uzi.tscn")

var score: int = 0
var kills: int = 0
var is_paused: bool = false
var buffed: bool = false

func _ready():
	#$player/Camera2D.current = true
	if $player.connect("died", Callable(self, "_on_player_died")):
		printerr("connection failed")
	if $HUD/restart_button.connect("pressed", Callable(self, "_on_restart")):
		printerr("connection failed")
	if $score_timer.connect("timeout", Callable(self, "_on_score_timer_timeout")):
		printerr("connection failed")
	if $enemy_manager.connect("enemy_killed", Callable(self, "_on_enemy_killed")):
		printerr("connection failed")
	
	$enemy_manager.player = $player
	$enemy_manager.HUD = $HUD
	$bullet_manager.player = $player

	for child in get_children():
		if child.has_method("_on_level_loaded"):
			child._on_level_loaded()
	start_game()

func _unhandled_input(event):
	if event.is_action_pressed("ui_pause"):
		if is_paused:
			resume()
		else:
			pause()

func pause():
	is_paused = true
	$enemy_manager.set_physics_process(false)
	$player.set_physics_process(false)
	$player/gun/fire_period.paused = true
	$score_timer.paused = true
	$HUD.paused_mode()

func resume():
	is_paused = false
	$player.set_physics_process(true)
	$enemy_manager.set_physics_process(true)
	$player/gun/fire_period.paused = false
	$score_timer.paused = false
	$HUD.playing_mode()

func _on_player_died():
	$player.set_physics_process(false)
	$player.current_gun.get_node("fire_period").stop()
	$score_timer.stop()
	$HUD.dead_mode()

func _on_restart() -> void:
	$enemy_manager.stop()
	start_game()

func _on_score_timer_timeout():
	score += 1
	$HUD.update_score(score)
	
func _on_enemy_killed():
	kills += 1
	$HUD.update_kscore(kills)

func pickup_gun(gun, gun_name):
	$player.add_gun_to_inventory(gun)
	$HUD.flash("Picked up %s!" % gun_name)

func buff():
	if buffed:
		return
	buffed = true
	pickup_gun(ShotgunClass, "Shotgun")
	await get_tree().create_timer(10).timeout
	$player.remove_gun_from_inventory(ShotgunClass)
	$HUD.flash("lost Shotgun...")
	buffed = false


func start_game() -> void:
	score = 0
	kills = 0
	$HUD.update_score(score)
	$HUD.update_kscore(kills)
	$HUD.playing_mode()
	$score_timer.start()
	
	$enemy_manager.start()

	$player.set_physics_process(true)
	$player.add_gun_to_inventory(UziClass)
	$player.set_gun($player.inventory_idx) # this is ugly.

	# temporary 
	var buff_timer = Timer.new()
	buff_timer.set_wait_time(15)
	add_child(buff_timer)
	buff_timer.start()
	buff_timer.connect("timeout", buff)

