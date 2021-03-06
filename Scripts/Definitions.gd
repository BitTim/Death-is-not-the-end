extends Node

signal settingsUpdateStart
signal settingsUpdateStop

# ================================
# Data
# ================================

var CONFIG = ConfigFile.new()

var TILE_DATA = {}
var STRING_IDS = {}
var ITEM_DATA = {}
var LEVEL_DATA = {}

var LOOTTABLES = {}
var ITEM_STARTFRAMES = {}

var LOADING_SCREEN_MESSAGES = {}

# ================================
# Scenes
# ================================

var PLAYER_SCENE = preload("res://Scenes/Entities/Player.tscn")
var ITEM_SCENE = preload("res://Scenes/GUI/Inventory/Item.tscn")
var TRANSITION_SCENE = preload("res://Scenes/Effects/TransitionShader.tscn")

var SPAWNABLE_SCENES = {}

# ================================
# Dimensions
# ================================

const DIMENSIONS = {1: "d_alive", 2: "d_dead"}

func getDimensionLayer(dimension):
	return DIMENSIONS.keys()[DIMENSIONS.values().find(dimension)]

func getDimensionIndex(dimension):
	return DIMENSIONS.values().find(dimension)

# ================================
# Util
# ================================

func _ready():
	var file = File.new()
	
	file.open("res://Data/tiles.json", file.READ)
	TILE_DATA = parse_json(file.get_as_text())
	
	file.open("res://Data/stringIDs.json", file.READ)
	STRING_IDS = parse_json(file.get_as_text())
	
	file.open("res://Data/items.json", file.READ)
	ITEM_DATA = parse_json(file.get_as_text())
	
	file.open("res://Data/levels.json", file.READ)
	LEVEL_DATA = parse_json(file.get_as_text())
	
	file.open("res://Data/loadingScreenMessages.json", file.READ)
	LOADING_SCREEN_MESSAGES = parse_json(file.get_as_text())
	
	file.open("res://Data/spawnableScenes.json", file.READ)
	var scenes = parse_json(file.get_as_text())
	
	file.open("res://Data/loottables.json", file.READ)
	LOOTTABLES = parse_json(file.get_as_text())
	
	ITEM_STARTFRAMES = generateItemStartframes()
	
	for scene in scenes:
		SPAWNABLE_SCENES[scene.id] = load(scene.scene)

func moveNode(src, dst):
	src.get_parent().remove_child(src)
	dst.add_child(src)
	src.set_owner(dst)
	
	return src

func generateItemStartframes():
	var startframes = {}
	var counter = 0
	
	for key in ITEM_DATA.keys():
		startframes[key] = counter
		counter += ITEM_DATA[key].numFrames
	
	return startframes
