extends Label
@onready var gd_timer: Timer = $GDTimer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = ""


# Called every frame. 'delta' is the elapsed time since the previous frame.
func gongdplayer(event:int) -> void:
	if event < 1000:
		text = "功德：%s"%event
	else :
		text = "功德无量"
	gd_timer.start()


func _on_gd_timer_timeout() -> void:
	text = ""
