extends Control

onready var def = get_node("/root/Definitions")

onready var chatlog = get_node("VBoxContainer/Panel/RichTextLabel")
onready var input = get_node("VBoxContainer/HBoxContainer/LineEdit")

var player = null

# ================================
# Util
# ================================

func _ready():
	input.connect("text_entered", self, "text_entered")

func givePlayerReference(player):
	self.player = player

func toggle():
	if visible:
		hide()
		input.grab_focus()
	else:
		show()
		input.release_focus()

func sendCommand(command):
	chatlog.bbcode_text += "[color=#999999]> " + command + "[/color]\n" 
	
	if player != null: parseCommand(command)

func text_entered(text):
	if text != "":
		sendCommand(text)
		input.text = ""

# ================================
# Commands
# ================================

func parseCommand(rawCommand):
	var command = rawCommand.split(" ", false)
	
	if command[0] == "/help":
		chatlog.bbcode_text += "Help Page\n" 
	
	elif command[0] == "/dimension":
		if command.size() != 2:
			chatlog.bbcode_text += "[color=#FF001D]Invalid arguments[/color]\n"
		else:
			if def.DIMENSIONS.values().has(command[1]):
				player.changeDimension(command[1])
				chatlog.bbcode_text += "Changed Dimension to: " + command[1] + "\n"
			else:
				chatlog.bbcode_text += "[color=#FF001D]Invalid dimension: " + command[1] + "[/color]\n"
	
	elif command[0] == "/kill":
		player._onReceiveDamage(999)
		chatlog.bbcode_text += "Killed Player \n"
		
	elif command[0] == "/damage":
		if command.size() != 2:
			chatlog.bbcode_text += "[color=#FF001D]Invalid arguments[/color]\n"
		else:
			if command[1].is_valid_integer():
				player._onReceiveDamage(int(command[1]))
				chatlog.bbcode_text += "Dealt " + command[1] + " Damage to Player \n"
			else:
				chatlog.bbcode_text += "[color=#FF001D]Inavlid amount: " + command[1] + "[/color]\n"
	
	elif command[0] == "/speed":
		if command.size() != 2:
			chatlog.bbcode_text += "[color=#FF001D]Invalid arguments[/color]\n"
		else:
			if command[1].is_valid_integer():
				player.speed = int(command[1])
				chatlog.bbcode_text += "Set Speed of player to " + command[1] + "\n"
			else:
				chatlog.bbcode_text += "[color=#FF001D]Inavlid amount: " + command[1] + "[/color]\n"
	
	elif command[0] == "/heal":
		if command.size() != 2:
			chatlog.bbcode_text += "[color=#FF001D]Invalid arguments[/color]\n"
		else:
			if command[1].is_valid_integer():
				player._onHealReceived(int(command[1]))
				chatlog.bbcode_text += "Healed player with " + command[1] + " HP\n"
			else:
				chatlog.bbcode_text += "[color=#FF001D]Inavlid amount: " + command[1] + "[/color]\n"
	
	elif command[0] == "/give":
		if command.size() != 3:
			chatlog.bbcode_text += "[color=#FF001D]Invalid arguments[/color]\n"
		else:
			if command[2].is_valid_integer() and def.ITEM_DATA.keys().find(command[1]) != -1:
				var returnVal = get_parent().get_node("Inventory").insertItem(command[1], int(command[2]))
				
				if returnVal == -1:
					chatlog.bbcode_text += "[color=#FF001D]Not enough space in Inventory[/color]\n"
				else:
					chatlog.bbcode_text += "Gave player " + command[1] + " x" + command[2] + "\n"
			else:
				chatlog.bbcode_text += "[color=#FF001D]Inavlid item: " + command[1] + " or amount: " + command[2] + "[/color]\n"
	
	elif command[0] == "/spawn":
		if command.size() != 6:
			chatlog.bbcode_text += "[color=#FF001D]Invalid arguments[/color]\n"
		else:
			var object = command[1].split(":", false)
			
			if def.SPAWNABLE_SCENES.keys().find(object[0]) == -1:
				chatlog.bbcode_text += "[color=#FF001D]Inavlid entity: " + command[1] + "[/color]\n"
			elif not command[2].is_valid_float() and command[2] != ".":
				chatlog.bbcode_text += "[color=#FF001D]Invalid X coordinate: " + command[2] + "[/color]\n"
			elif not command[3].is_valid_float() and command[3] != ".":
				chatlog.bbcode_text += "[color=#FF001D]Invalid Y coordinate: " + command[3] + "[/color]\n"
			elif not command[4].is_valid_float() and command[4] != ".":
				chatlog.bbcode_text += "[color=#FF001D]Invalid X scale: " + command[4] + "[/color]\n"
			elif not command[5].is_valid_float() and command[5] != ".":
				chatlog.bbcode_text += "[color=#FF001D]Invalid Y scale: " + command[5] + "[/color]\n"
			else:
				var spawnHelper = player.get_parent().get_node("SpawnHelper")
				var args = []
				
				args.append(command[2])
				args.append(command[3])
				args.append(command[4])
				args.append(command[5])
				
				if args[0] == ".": args[0] = spawnHelper.posToCoords(player.get_position()).x
				if args[1] == ".": args[1] = spawnHelper.posToCoords(player.get_position()).y
				if args[2] == ".": args[2] = 1
				if args[3] == ".": args[3] = 1
				
				var obj = spawnHelper.spawn(object[0], Vector2(int(args[0]), int(args[1])), Vector2(int(args[2]), int(args[3])), "", player.get_parent().currentDimensionID)
				if object.size() > 1: obj.setType(object[1])
				
				chatlog.bbcode_text += "Spawned " + command[1] + " at pos: (" + str(args[0]) + ", " + str(args[1]) + ") with scale (" + str(args[2]) + "," + str(args[3]) +")\n"
	
	elif command[0] == "/tp":
		if command.size() != 3:
			chatlog.bbcode_text += "[color=#FF001D]Invalid arguments[/color]\n"
		else:
			if command[2].is_valid_integer() and command[1].is_valid_integer():
				player.position = player.get_parent().get_node("SpawnHelper").coordsToPos(Vector2(command[1], command[2]))
				chatlog.bbcode_text += "Teleported player to: (" + command[1] + ", " + command[2] + ")\n"
			else:
				chatlog.bbcode_text += "[color=#FF001D]Invalid Position: (" + command[1] + ", " + command[2] + ")[/color]\n"
	
	elif command[0] == "/god":
		if command.size() != 2:
			chatlog.bbcode_text += "[color=#FF001D]Invalid arguments[/color]\n"
		else:
			if command[1] == "on":
				player.invincibility = true
				chatlog.bbcode_text += "Enabled god mode\n"
			elif command[1] == "off":
				player.invincibility = false
				chatlog.bbcode_text += "Disabled god mode\n"
			else:
				chatlog.bbcode_text += "[color=#FF001D]Invalid option: " + command[1] + "[/color]\n"
	
	elif command[0] == "/noclip":
		if command.size() != 2:
			chatlog.bbcode_text += "[color=#FF001D]Invalid arguments[/color]\n"
		else:
			if command[1] == "on":
				player.get_node("CollisionShape2D").disabled = true
				chatlog.bbcode_text += "Enabled noclip\n"
			elif command[1] == "off":
				player.get_node("CollisionShape2D").disabled = false
				chatlog.bbcode_text += "Disabled noclip\n"
			else:
				chatlog.bbcode_text += "[color=#FF001D]Invalid option: " + command[1] + "[/color]\n"
	
	else:
		chatlog.bbcode_text += "[color=#FF001D]Command not found[/color]\n"
