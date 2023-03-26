extends Control

onready var record_bus = AudioServer.get_bus_index($AudioStreamRecord.bus)
onready var record = AudioServer.get_bus_effect(record_bus, 0)

func _on_Record_toggled(button_pressed):
	$VBoxContainer/Test.disabled = button_pressed
	$VBoxContainer/Save.disabled = button_pressed
	record.set_recording_active(button_pressed)
	
	if not button_pressed:
		$TestPlayer.stream = record.get_recording()
		
func _on_Test_pressed():
	$TestPlayer.play()

func _on_Save_pressed():
#	$FileDialog.popup_centered()
	$TestPlayer.stream.save_to_wav("user://record_data")

func _on_FileDialog_file_selected(path):
	pass

func save(content):
	var OutputFile = File.new()
	OutputFile.open("user://record_data.mp3", File.WRITE)
	OutputFile.store_buffer(content)
	OutputFile.close()
