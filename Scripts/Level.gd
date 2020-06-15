extends Node2D

onready var def = get_node("/root/Definitions")
onready var vars = get_node("/root/PlayerVars")

export (int, FLAGS, "Alive", "Dead") var availableDimensions
export (String) var levelName

var dimensions = []
var currentDimension = null
var prevDimension = null
var currentDimensionID = 0

var player = null

# ================================
# Util
# ================================

func _ready():
	loadDimensions()
	loadPlayer()
	
	connectSignals()
	setSpawn()
	
func spawn():
	spawnObjects(currentDimension.get_node("Items"), $Items, def.ITEM_SCENES)
	spawnObjects(currentDimension.get_node("Enemies"), $Enemies, def.ENEMY_SCENES)
	spawnObjects(currentDimension.get_node("Interactables"), $Interactables, def.INTERACTABLE_SCENES)

func initPlayer(gui):
	if player != null:
		vars.initHealth(player.maxHealth)
		player.initGUI(gui)
		gui.player = player

func loadDimensions():
	for i in def.NUM_DIMENSIONS:
		var dimension = availableDimensions & (1 << i)
		if dimension != 0:
			dimensions.append(load(str("res://Scenes/Levels/" + levelName + "/Dimensions/" + def.DIMENSION_STRINGS[dimension] + ".tscn")))

func loadPlayer():
	player = def.PLAYER_SCENE.instance()
	add_child(player)

func connectSignals():
	player.connect("changeDimension", self, "changeDimension")

# ================================
# Spawns
# ================================

func setSpawn():
	if currentDimension == null: changeDimension(def.DIMENSION_ALIVE)
	player.position = currentDimension.get_node("Spawn").position * currentDimension.scale * 2

func spawnObjects(spawnMap, objectParent, scenes):
	var objects = spawnMap.get_used_cells()
	
	for i in objects.size():
		var objectID = spawnMap.get_cellv(objects[i])
		var object = scenes[objectID].instance()
		
		objectParent.add_child(object)
		object.position = spawnMap.map_to_world(objects[i]) * currentDimension.scale
		object.changeDimension(currentDimensionID)
	
	spawnMap.clear()

# ================================
# Actions
# ================================

func changeDimension(dimension):
	dimension = int(dimension)
	
	if dimensions.size() == 0:
		print("No Dimensions Loaded")
		return
	
	if currentDimension == null:
		currentDimensionID = def.DIMENSION_ALIVE
		currentDimension = dimensions[def.logB(def.DIMENSION_ALIVE, 2)].instance()
		$Dimension.add_child(currentDimension)
	
	if availableDimensions & dimension != 0:
		prevDimension = currentDimension
		currentDimensionID = dimension
		currentDimension = dimensions[def.logB(dimension, 2)].instance()
		
		$Dimension.add_child(currentDimension)
		prevDimension.queue_free()
		
	# Hide SpawnMaps
	currentDimension.get_node("Items").hide()
	currentDimension.get_node("Enemies").hide()
	currentDimension.get_node("Interactables").hide()
	
	for i in $Items.get_children(): i.changeDimension(dimension)
	for e in $Enemies.get_children(): e.changeDimension(dimension)
	for s in $Interactables.get_children(): s.changeDimension(dimension)
