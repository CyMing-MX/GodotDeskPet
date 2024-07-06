extends Label

class_name chattext
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer

func _ready() -> void:
	get_parent().hide()

# Called when the node enters the scene tree for the first time.
func play_chat() ->void:
	animation_player.play("chattext")
	timer.start()
	get_parent().show()

func _on_timer_timeout() -> void:
	visible_ratio = 0
	Game_manager.text_showing = false
	get_parent().hide()

