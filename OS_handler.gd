extends Node2D

#func _ready():
#	if OS.get_name() == "Windows":
#		check_process_windows("twitter")
#	elif OS.get_name() == "X11" or OS.get_name() == "Linux":
#		check_process_linux("steam")
#	else:
#		print("Unsupported platform")
#
#func check_process_windows(process_name: String):
#	var output = []
#	OS.execute("tasklist", [], true, output)
#
#	for line in output:
#		if process_name in line:
#			print("Process found:", process_name)
#			return
#
#	print("Process not found:", process_name)
##	print(output[0])
#
#func check_process_linux(process_name: String):
#	var output = []
#	OS.execute("ps", ["-e", "-o", "comm="], true, output)
#
#	for line in output:
#		if line.strip() == process_name:
#			print("Process found:", process_name)
#			return
#
#	print("Process not found:", process_name)
