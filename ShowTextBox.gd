extends Button

var icon_hovered = preload("res://sprite/text_hover.png")
var icon_default = preload("res://sprite/text_default.png")
var icon_pressed = preload("res://sprite/text_pressed.png")
onready var ClippyScene = get_node("/root/ClippyScene")
onready var InputText = get_node("/root/ClippyScene/SendButton/InputText")
onready var SendButton = get_node("/root/ClippyScene/SendButton")
var isbuttondown = false

func _on_ShowTextBox_button_down():
	isbuttondown = true
	if SendButton.visible == true:
		InputText.visible = false
		SendButton.visible = false
	else:
		InputText.visible = true
		SendButton.visible = true

func _on_ShowTextBox_button_up():
	isbuttondown = false
	
func _process(delta):
	if ClippyScene.CanSend == true:
		self.disabled = false
		if self.is_hovered() == true and isbuttondown == false:
			self.icon = icon_hovered
		if self.is_hovered() == true and isbuttondown == true:
			self.icon = icon_pressed
		if self.is_hovered() == false and isbuttondown == false:
			self.icon = icon_default
		return
	else:
		self.disabled = true
