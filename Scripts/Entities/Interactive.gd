extends StaticBody2D

onready var def = get_node("/root/Definitions")
onready var vars = get_node("/root/PlayerVars")

export (String) var id
export (int, FLAGS, "Alive", "Dead") var layer
export (Array, int) var dimensionOffsets
export (int, FLAGS, "Alive", "Dead") var canInteract
export (int) var cooldown

var onCooldown = false
var currentDimension = ""

var health = -1
var state = 0

# ================================
# Util
# ================================

func _ready():
	$Interaction.connect("body_entered", self, "_onEntered")
	$Interaction.connect("body_exited", self, "_onExited")
	
	$Timer.wait_time = cooldown
	$Timer.connect("timeout", self, "_onCooldownTimeout")
	
	$AnimationPlayer.play("Idle")

func _process(delta):
	$CooldownBar.changeHealth($Timer.time_left * 100, $Timer.wait_time * 100)

func _onCooldownTimeout():
	onCooldown = false
	$CooldownBar.hide()
	
	var bodies = $Interaction.get_overlapping_bodies()
	for body in bodies:
		if "Player" in body.name:
			$E.show()
			if onCooldown: $CooldownBar.show()
			body.interact = self

# ================================
# Actions
# ================================

func changeDimension(dimension):
	if def.getDimensionLayer(dimension) & layer != 0:
		show()
		$CollisionShape2D.disabled = false
		
		if def.getDimensionLayer(dimension) & canInteract != 0: 
			$Interaction/CollisionShape2D.disabled = false
			$Light2D.show()
		else:
			$Interaction/CollisionShape2D.disabled = true
			$Light2D.hide()
		
		$Sprite.region_rect.position.y = dimensionOffsets[def.getDimensionIndex(dimension)]
		
		var bodies = $Interaction.get_overlapping_bodies()
		for body in bodies:
			if "Player" in body.name:
				$E.show()
				if onCooldown: $CooldownBar.show()
				body.interact = self
	else:
		hide()
		$CollisionShape2D.disabled = true
		$Interaction/CollisionShape2D.disabled = true

func setType(_type):
	pass

# ================================
# Interaction
# ================================

func _onEntered(body):
	if !onCooldown:
		if "Player" in body.name:
			$E.show()
			body.interact = self
	else:
		$CooldownBar.show()

func _onExited(body):
	if "Player" in body.name:
		$E.hide()
		$CooldownBar.hide()
		body.interact = null

func interact(player):
	if !onCooldown:
		onCooldown = true
		$CooldownBar.changeHealth($Timer.wait_time, $Timer.wait_time)
		$Timer.start()
		
		if id == "n_altar":
			player.changeDimension("d_alive")
			vars.dead = false
