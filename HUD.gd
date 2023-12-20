extends CanvasLayer

func _ready():
	$spawn_rate.show_percentage = false
	if $flash_label/timer.connect("timeout", _on_flash_timeout):
		printerr("could not connect to signal")

func update_score(score: int) -> void:
	$score_label.text = str(score)

func update_kscore(kills: int) -> void:
	$kscore_label.text = str(kills)

func playing_mode() -> void:
	$paused_label.hide()
	$restart_button.hide()

func dead_mode() -> void:
	$restart_button.show()

func paused_mode() -> void:
	$paused_label.show()

func flash(message):
	$flash_label.text = message
	$flash_label.show()
	$flash_label/timer.start()

func _on_flash_timeout():
	$flash_label.hide()
