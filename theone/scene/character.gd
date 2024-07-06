extends Node2D
class_name Character

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

@onready var drinktimer: Timer = $drinktimer
@onready var walktimer: Timer = $walktimer
@onready var savetimer: Timer = $savetimer
@onready var sleeptimer: Timer = $sleeptimer
@onready var awaketimer: Timer = $awaketimer



@onready var head_2d: Area2D = $head2D
@onready var body_2d: Area2D = $body2D
@onready var leg_2d: Area2D = $leg2D
@onready var hair_2d: Area2D = $hair2D


signal chat_hair
signal chat_head
signal chat_body
signal chat_legs
signal chat_warn
signal chat_awake
signal chat_gd
#一共六个状态：空闲，说话，提醒，睡眠，拖拽和敲功德
enum  state {
	IDLE = 0,
	SPEAKING,
	WARN,
	SLEEP,
	DRAG,
	GONGD,
}
#这个是加载音频文件
var sounds := [load("res://asset/mp333/dianji.mp3"),load("res://asset/mp333/tixing1.mp3"),load("res://asset/mp333/tixing2.mp3")]
#一堆初始化设置
var current_state := state.IDLE
var next_state := -1
var speakingflag := false
var sleepflag := false
var drinkflag := false
var walkflag := false
var saveflag := false
var can_drag:= true
var stopplay := false
var gdflage := false
var dragflag : bool
var mouse_position: Vector2i

var idle_animations := ["breath1","breath1","breath1","breath1","breath2","breath2","breath3"]
var sleep_animations := ["sleep1","sleep2"]
#用于从某一状态进入下一个状态的条件判断
func get_next_state() -> int:
	match  current_state:
		state.IDLE:
			if speakingflag and !sleepflag:
				return state.SPEAKING
				
			if sleepflag and !Game_manager.text_showing:
				animation_player.play("dunxia")
				return state.SLEEP
				
			if !Game_manager.text_showing and drinkflag or walkflag or saveflag:
				return state.WARN
				
			if !Game_manager.text_showing and dragflag :
				return state.DRAG
				
			if !Game_manager.text_showing and Game_manager.gd_play :
				return state.GONGD
				
		state.DRAG:
			if !dragflag:
				return state.IDLE
			
		state.SPEAKING:
			if (!animation_player.is_playing()):
				speakingflag = false
				sleepflag = false
				return state.IDLE

		state.WARN:
			if(!animation_player.is_playing()):
				sleepflag = false
				return state.IDLE
				
		state.GONGD:
			if !Game_manager.gd_play:
				return state.IDLE
			
		state.SLEEP:
			if (!sleepflag):
				return state.IDLE
			elif speakingflag:
				sleepflag = false
				chat_awake.emit()
				return state.IDLE
			if dragflag:
				return state.DRAG
	return -1
#进入新状态后需要进行的事情
func goto_new_state() -> void:
	match  current_state:
		state.IDLE:
			sleeptimer.start()
			can_drag = true
			hair_2d.input_pickable = true
			head_2d.input_pickable = true
			body_2d.input_pickable = true
			leg_2d.input_pickable = true
			
		state.SPEAKING:
			Game_manager.text_showing = true
			can_drag = false
			hair_2d.input_pickable = false
			head_2d.input_pickable = false
			body_2d.input_pickable = false
			leg_2d.input_pickable = false
			audio_player_2d.stream = sounds[0]
			audio_player_2d.play()
			
		state.WARN:
			chat_warn.emit()
			Game_manager.text_showing = true
			can_drag = false
			hair_2d.input_pickable = false
			head_2d.input_pickable = false
			body_2d.input_pickable = false
			leg_2d.input_pickable = false
			audio_player_2d.stream = sounds[randi()%2+1]
			audio_player_2d.play()
		
		state.GONGD:
			chat_gd.emit()
			can_drag = false
			hair_2d.input_pickable = false
			head_2d.input_pickable = false
			body_2d.input_pickable = false
			leg_2d.input_pickable = false
			
		state.SLEEP:
			awaketimer.start()
			
		state.DRAG:
			hair_2d.input_pickable = false
			head_2d.input_pickable = false
			body_2d.input_pickable = false
			leg_2d.input_pickable = false
			
#用于需要长时间保持的状态，比如空闲和睡觉的时候需要一直播放相应的动画
func do_current_state() -> void:
	match  current_state:
		state.IDLE:
			if (!animation_player.is_playing()) or stopplay:
				animation_player.play(idle_animations.pick_random())
				stopplay = false
				
		state.SPEAKING:
			pass
			
		state.WARN:
			pass
			
		state.SLEEP:
			if (!animation_player.is_playing()):
				animation_player.play(sleep_animations.pick_random())
				
		state.DRAG:
			pass
			
		state.GONGD:
			pass
#每一帧刷新，用于获取新状态并进入下一状态
func _physics_process(delta: float) -> void:
	next_state = get_next_state()
	if next_state != -1:
		current_state = next_state
		goto_new_state()
	do_current_state()
#右键长按实现拖拽（说实话按照这个逻辑写还是会卡顿），右键双击打开功德状态的flag
func _on_character_body_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	var Window_position:Vector2
	var screen:Vector2
	var windowsize:Vector2
	screen = DisplayServer.screen_get_size()
	windowsize = get_viewport_rect().size
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.double_click:
				Game_manager.gd_play = true
			
	
	if can_drag :
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				if event.pressed :
					dragflag = true
					mouse_position = get_global_mouse_position()
				else :
					dragflag = false
				
		if dragflag and event is InputEventMouseMotion:
			stopplay = true
			animation_player.play("drugg")
			Window_position = DisplayServer.mouse_get_position()-mouse_position
			DisplayServer.window_set_position(Window_position)
			if get_tree().root.position.x <0:
				DisplayServer.window_set_position(Vector2(0,Window_position.y))
			if get_tree().root.position.y <0:
				DisplayServer.window_set_position(Vector2(Window_position.x,0))
			if get_tree().root.position.x + windowsize.x >screen.x:
				DisplayServer.window_set_position(Vector2(screen.x-windowsize.x,Window_position.y))
			if get_tree().root.position.y + windowsize.y >screen.y:
				DisplayServer.window_set_position(Vector2(Window_position.x,screen.y-windowsize.y))
							

			
			
			
			#我不知道怎么才能根据移动的方向设置不同的动画。。。总之先放个在这
			#if get_tree().root.position[0] < Window_position.x:
				#animation_player.play("drugleft")
			#
			#elif get_tree().root.position[0] > Window_position.x:
				#animation_player.play("drugright")
			#
			#else :
				#animation_player.play("drugg")



#以下几个都是用于不同部位被点击后发出相应信号，以显示不同文本
func _on_head_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_released("chatstart"):
		chat_head.emit()
		speakingflag = true
	

func _on_body_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_released("chatstart"):
		chat_body.emit()
		speakingflag = true


func _on_leg_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_released("chatstart"):
		chat_legs.emit()
		speakingflag = true


func _on_hair_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_released("chatstart"):
		chat_hair.emit()
		speakingflag = true

#下面是几个提醒的计时器
func _on_drinktimer_timeout() -> void:
	drinkflag = true


func _on_walktimer_timeout() -> void:
	walkflag = true


func _on_savetimer_timeout() -> void:
	saveflag = true


func _on_sleeptimer_timeout() -> void:
	sleepflag = true

#这个是睡觉状态持续一定时间后会自动返回空闲状态
func _on_awaketimer_timeout() -> void:
	if sleepflag:
		animation_player.play("awake")
		sleepflag = false
	else :
		awaketimer.start()
		

