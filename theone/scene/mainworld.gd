extends Control
@onready var weatherapi: HTTPRequest = $weatherapi
@onready var character: Character = $character
@onready var panel_container: PanelContainer = $PanelContainer
@onready var chattext: chattext = $PanelContainer/chattext
@onready var g_dplus: Label = $GDplus
@onready var g_dplayer: AnimationPlayer = $GDplus/GDplayer
@onready var g_dcount: Label = $GDcount
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D



var sentences_head : Array[Array]
var sentences_body : Array[Array]
var sentences_legs : Array[Array]
var sentences_hair : Array[Array]
var sentences_rate : Array[float]
var sentences_warn : Array[String]
var sentences_awake : Array[String]

var theday :String
var temperature :String
var thetime :int
var gdcount :int
var theweek :String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().root.set_transparent_background(true)
	requestwheather()
	start()
	
	sentences_rate = [0.001,0.01,0.1,0.1,0.1,0.1,0.1,0.06,0.05,0.1,0.05,0.05,0.05,0.02,0.01,0.099] 
	
	sentences_head = [
		["我是一只\r\n脆弱的小鸡仔","sad"],
		["想吃鸡锁骨\r\n＞︿＜","eat1"],
		["我有点困了...","speak"],
		["今天~\r\n过得怎么样","happyer"],
		["","speak"],
		["","speak"],
		["","speak"],
		["我喜欢\r\n拿乌梅干泡面","eat2"],
		["别管我，\r\n我在纠结...","sad"],
		["喜欢摸摸头~","happyer"],
		["我不会拒绝别人","sad"],
		["今天●◡●\r\n过得怎么样~","happyer"],
		["你的桌面\r\n好多文件呀","speak"],
		["不想学习……","sad"],
		["我有点晕字了……","sad"],
		["双击右键\r\n有惊喜","speak"]
		]
		
	sentences_body = [
		["不许摸了！","angerer"],
		["别再褥我了！","angerer"],
		["我的肚子\r\n毛茸茸的","happyer"],
		["你在做什么？\r\n让我看看","speak"],
		["好饿啊，\r\n想吃外卖了","sad"],
		["我觉得\r\n我需要锻炼","speak"],
		["又来陪我玩了？","happyer"],
		["我长大后\r\n会成为医生哦","speak"],
		["我也摸摸\r\n你的肚子","happyer"],
		["今天的任务\r\n完成了吗?","speak"],
		["运动？\r\n下次一定！","happyer"],
		["","happyer"],
		["好好吃饭\r\n我做到了,你呢？","eat1"],
		["又吃多了\r\n呜呜","sad"],
		["今天吃了\r\n三顿饭","eat2"],
		["欢迎来攒\r\n赛博功德","speak"],
		]
	
	sentences_legs = [
		["今天我\r\n哪里也没去","sad"],
		["你想出去玩吗","happyer"],
		["我今天的步数\r\n是两位数","sad"],
		["先说好\r\n你不吃鸡腿","sad"],
		["我的脚上\r\n有东西吗?","speak"],
		["这里\r\n没什么好戳的","speak"],
		["你有什么\r\n想去的地方吗","happyer"],
		["哼！\r\n不会被绊倒的","angerer"],
		["就算不穿鞋，\r\n屏幕也不扎脚","speak"],
		["可以\r\n右键移动我","speak"],
		["站着好累……","angerer"],
		["坐累了？\r\n那就站一会","speak"],
		["这个地方\r\n呆得不舒服","sad"],
		["我有四根脚趾","happyer"],
		["和你一样\r\n我也是两足兽","speak"],
		["现在还没有功德","speak"]
		]
		
	sentences_warn = [
		"学了这么久\r\n休息一下吧","定时休息\r\n效率更高哦","这么专注！\r\n你最棒啦！",
		"我猜你渴了\r\n喝点水么","起来走走吧\r\n记得喝水~","多喝水可以\r\n缓解疲劳~",
		"学得怎么样\r\n记得保存文件哦","记得按\r\n保存键哦","这种大作！\r\n记得保存呀~",
	]
	
	sentences_awake = [
		"谁在打扰\r\n我睡觉？",
		"我还没梦到\r\n结局呢",
		"发生\r\n什么事了吗",
		"我醒了，\r\n我醒了",
		"呜呜QWQ，\r\n做噩梦了",
		"刚刚梦见\r\n自己被吃了",
		"梦见你了！",
		"刚刚见到\r\n我的好朋友了",
		"好像流口水了",
		"好困……\r\n我还没睡醒",
		"不小心睡着了",
		"我睡了多久？",
		"你的屏幕\r\n呆着很舒服",
		"你刚刚是不是\r\n戳了我一下",
		"梦见自己\r\n被做成烤鸡了"
	]
	
	sentences_hair = [
		["这是我的\r\n聪明毛","happyer"],
		["再摸就要秃了","sad"],
		["痒痒的\r\n要长脑子了","speak"],
		["发型……乱了","angerer"],
		["怎么样\r\n手感好吧","speak"],
		["这个洗发水\r\n效果不错","speak"],
		["轻点揪QWQ","sad"],
		["你是什么发型？","drink1"],
		["这么多头发\r\n羡慕吧？","happyer"],
		["你的爪子！\r\n老实点！","angerer"],
		["我要啄你了","angerer"],
		["想换个造型","drink1"],
		["染发？\r\n没有这个条件","sad"],
		["手感怎么样？","speak"],
		["想要请你\r\n帮我梳毛","happyer"],
		["你想敲木鸡吗","speak"],
	]
	
	gdcount = 0
	
	gettime()
	food_to_eat()

func start() -> void:
	var sentences_start = ["你好，\r\n我是世轩鸡","左键点击\r\n听我说话","长按右键\r\n移动我","双击右键\r\n可以敲木鸡","Alt+P\r\n退出桌宠","还有很多内容\r\n期待你的探索~"]
	for i in range(len(sentences_start)):
		Game_manager.text_showing = true
		chattext.text = sentences_start[i]
		character.animation_player.play("happyer")
		chattext.play_chat()
		await chattext.timer.timeout
		


func  _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("quitgame"):
		get_tree().quit()

func  requestwheather() -> void:
	weatherapi.request("https://restapi.amap.com/v3/weather/weatherInfo?Key=38374aa3758ae5eead673d2c90bc0ced&city=430104")

func update_gd() ->void:
	if gdcount > 100 :
		sentences_body[15][0] = "目前的功德\r\n破百了！"
		sentences_head[15][0] = "涨功德的同时\r\n可以涨智力吗"
		sentences_legs[15][0] = "现在的功德\r\n比走的路还多"
		sentences_hair[15][0] = "功德让我\r\n更加聪明！"
		sentences_body[15][1] = "happyer"
		sentences_head[15][1] = "happyer"
		sentences_legs[15][1] = "happyer"
		sentences_hair[15][1] = "happyer"
	elif gdcount > 0 :
		sentences_body[15][0] = "没事可以\r\n敲敲木鸡"
		sentences_head[15][0] = "已经攒了%s\r\n的功德！"%gdcount
		sentences_legs[15][0] = "功德好少\r\n呜呜"
		sentences_hair[15][0] = "目前被敲了\r\n%s下"%gdcount
	else:
		pass


func food_to_eat() ->void:
	var sentences_food = ["鸭腿饭","泡面","炒饭","银耳羹","冰糖雪梨","转转火锅","烤肠","火龙果","蛋包肠","自助烤肉","肠粉","茶叶蛋","鸡胸肉","食堂","饺子","红豆面包"]
	var randomin = sentences_food.pick_random()
	sentences_body[11][0] = "今天吃了\r\n" + randomin

	
func gettime() -> void:
	var times = Time.get_datetime_dict_from_system() as Dictionary
	var weekkey = {"工作日":{1:"周一",2:"周二",3:"周三",4:"周四",5:"周五"},"周末":{6:"周六",7:"周日"}}
	if times.weekday in [1,2,3,4,5]:
		theweek = weekkey["工作日"][times.weekday] as String
		sentences_head[5][0] = "今天是" + theweek + "\r\n工作日辛苦啦"
	else :
		theweek = weekkey["周末"][times.weekday] as String
		sentences_head[5][0] = "今天是" + theweek + "\r\n要好好休息哦"
		
	thetime = times.hour
	if thetime in [23,0,1,2,3,4]:
		sentences_head[6][0] = "已经%s点了,\r\n快睡觉吧~"%thetime
	elif thetime in [5,6,7,8,9,10]:
		sentences_head[6][0] = "现在是%s点,\r\n早上好！"%thetime
	elif thetime in [11,12,13]:
		sentences_head[6][0] = "现在是%s点,\r\n吃中饭了么"%thetime
	elif thetime in [14,15,16]:
		sentences_head[6][0] = "现在是%s点,\r\n下午好！"%thetime
	elif thetime in [17,18,19]:
		sentences_head[6][0] = "现在是%s点,\r\n吃晚饭了么"%thetime	
	elif thetime in [20,21,22]:
		sentences_head[6][0] = "现在是%s点,\r\n晚上好！"%thetime	
		
	



func _on_weatherapi_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var json := JSON.parse_string(body.get_string_from_utf8()) as Dictionary
	theday = json.lives[0].weather as String
	temperature = json.lives[0].temperature as String
	if "雨" in theday :
		sentences_head[4][0] = "今天" + theday + "，\r\n记得带伞~\r\n温度是" + temperature + "℃！"
		
	elif "晴" in theday:
		sentences_head[4][0] = "今天" + theday + "，\r\n注意防晒~\r\n温度是" + temperature + "℃！"
		
	else :
		sentences_head[4][0] = "今天" + theday + "，\r\n温度是" + temperature + "℃！"



func _on_weath_timer_timeout() -> void:
	requestwheather()
	gettime()


func _on_character_chat_body() -> void:
	var index := randf()
	var temper = 0
	for i in (sentences_body.size()):
		temper += sentences_rate[i]
		if index <= temper: 
			chattext.text = sentences_body[i][0]
			character.animation_player.play(sentences_body[i][1])
			chattext.play_chat()
			break



func _on_character_chat_head() -> void:
	var index := randf()
	var temper = 0
	for i in (sentences_body.size()):
		temper += sentences_rate[i]
		if index <= temper: 
			chattext.text = sentences_head[i][0]
			character.animation_player.play(sentences_head[i][1])
			chattext.play_chat()
			break



func _on_character_chat_legs() -> void:
	var index := randf()
	var temper = 0
	for i in (sentences_body.size()):
		temper += sentences_rate[i]
		if index <= temper: 
			chattext.text = sentences_legs[i][0]
			character.animation_player.play(sentences_legs[i][1])
			chattext.play_chat()
			break

func _on_character_chat_hair() -> void:
	var index := randf()
	var temper = 0
	for i in (sentences_hair.size()):
		temper += sentences_rate[i]
		if index <= temper: 
			chattext.text = sentences_hair[i][0]
			character.animation_player.play(sentences_hair[i][1])
			chattext.play_chat()
			break

func _on_character_chat_warn() -> void:
	var animatpick = ["drink1","drink1","drink2","eat1","eat1","eat2"]
	if character.walkflag:
		var indiexx = randi() % 3
		chattext.text = sentences_warn[indiexx]
		character.animation_player.play(animatpick.pick_random())
		chattext.play_chat()
		character.walktimer.start()
		character.walkflag = false
		return
		
	if character.drinkflag:
		var indiexx = 3 + randi() % 3
		chattext.text = sentences_warn[indiexx]
		character.animation_player.play(animatpick.pick_random())
		chattext.play_chat()
		character.drinktimer.start()
		character.drinkflag = false
		return
		
	if character.saveflag:
		var indiexx = 6 + randi() % 3
		chattext.text = sentences_warn[indiexx]
		character.animation_player.play("speaklould")
		chattext.play_chat()
		character.savetimer.start()
		character.saveflag = false
		return
		


func _on_character_chat_awake() -> void:
	var index = randi_range(0,len(sentences_awake)-1)
	chattext.text = sentences_awake[index]
	character.animation_player.play("awake")
	chattext.play_chat()
	return



func _on_character_chat_gd() -> void:
	var randpick = ["gdplus1",'gdplus2']
	gdcount += 1
	g_dcount.gongdplayer(gdcount)
	character.animation_player.play("big")
	g_dplayer.play(randpick.pick_random())
	update_gd()
	Game_manager.gd_play = false 
