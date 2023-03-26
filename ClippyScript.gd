extends KinematicBody2D
var ClippyState = ""
var ClippyMouseState = "NoMouseOver"
onready var timerfinished = false
onready var LongMouseOver = false
signal on_ClippyMouseOver_5sec
signal BeenClickedOnALot
onready var clickcounter = 0
var _last_mouse_position
onready var _pm = $PopupMenu
onready var TextBubbleContainer = get_node("/root/ClippyScene/TextBubbleContainer")
onready var ClippyScene = get_node("/root/ClippyScene")
onready var mouse_left_down
var click_pos = Vector2.ZERO
var has_dragged = false

func _ready():
	ClippyState = "Default"
	_pm.add_item("Exit without saving",0)
	_pm.add_item("Delete memory and exit",1)
	_pm.add_item("Save and exit",2)
	_pm.add_item("Enable always on top",3)
	_pm.set_item_disabled(2, true)

func _process(_delta):
	if Input.is_action_just_pressed("ui_touch"):
		click_pos = get_local_mouse_position()
	if ClippyScene.CanSend == true:
		_pm.set_item_disabled(2, false)
	else:
		_pm.set_item_disabled(2, true)
	$ClippyState.text = ClippyState + " " + ClippyMouseState
	if clickcounter == 10:
		emit_signal("BeenClickedOnALot")
	if mouse_left_down == true:
		
		var oldwindowpos = OS.window_position
		if get_local_mouse_position() != click_pos:
			OS.set_window_position(OS.window_position + get_local_mouse_position() - click_pos)
			has_dragged = true

func _on_ClippyObject_mouse_entered():
	ClippyMouseState = "MouseOver"
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	$MouseOverTimer.start()

func _on_ClippyObject_mouse_exited():
	ClippyMouseState = "NoMouseOver"
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	$MouseOverTimer.stop()
	$MouseOverTimer.wait_time = 5
	LongMouseOver = false
	$ClickResetTimer.start()

func _on_MouseOverTimer_timeout():
	LongMouseOver = true
	emit_signal("on_ClippyMouseOver_5sec")


func _on_ClippyObject_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("ui_touch"):
		clickcounter += 1
		print(clickcounter)
		$MouseOverTimer.stop()
		$ClickResetTimer.stop()
	if event.is_action_released("ui_touch"):
		print("unclicked on clippy")
		if has_dragged == false:
			if TextBubbleContainer.visible == true:
				TextBubbleContainer.visible = false
			else:
				TextBubbleContainer.visible = true
		has_dragged = false
	if has_dragged == true:
		$MouseOverTimer.stop()

	#CHECK FOR CLICK
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_pressed():
			mouse_left_down = true
			print("Mouse pressed")


	#POPUP MENU
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_RIGHT:
		_last_mouse_position = get_global_mouse_position()
		$PopupMenu.popup(Rect2(_last_mouse_position.x, _last_mouse_position.y, _pm.rect_size.x, _pm.rect_size.y))

func _on_ClickResetTimer_timeout():
	clickcounter = 0
#	print("clickresettimer ran out")

func _input(event):
	if event is InputEventMouseButton:
		 if event.button_index == 1 and not event.is_pressed():
				click_pos = get_local_mouse_position()
				mouse_left_down = false
				print("Mouse relaxed")

