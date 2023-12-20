extends Node2D

var player: Player


func _on_level_loaded():
	if player.connect("fired", _on_player_fired):
		printerr("connection failed")

func _on_player_fired(bullets) -> void:
	for bullet in bullets:
		add_child(bullet)
		if bullet.connect("body_entered", _on_bullet_hit.bind(bullet)):
			printerr("connection failed")

func _physics_process(delta):
	for bullet in get_children():
		if bullet is Bullet:
			bullet.position += bullet.vel * delta

func _on_bullet_hit(body: Node, bullet: Bullet) -> void:
	if body.has_method("take_bullet"):
		body.take_bullet(bullet.damage)
		bullet.queue_free()
