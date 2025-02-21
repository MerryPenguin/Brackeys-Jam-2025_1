extends HBoxContainer

@export var factory_building : Globals.buildings = Globals.buildings.INORGANICS
@export var purchase_price : int = 200
@export var icon : AtlasTexture

func _ready():
	hide_if_unlocked()
	setup_button_and_text()

func hide_if_unlocked():
	if Globals.unlocked_buildings.has(factory_building):
		queue_free()
	
func setup_button_and_text():
	var ref_scene = Globals.building_scenes[factory_building].instantiate()
	$Button.icon = icon
	$Label.text = ref_scene.short_name + ": $" + str(purchase_price)
	ref_scene.queue_free()
	

func _on_button_pressed() -> void:
	if not Globals.unlocked_buildings.has(factory_building):
		Globals.unlocked_buildings.push_back(factory_building)
		Globals.cash -= purchase_price
		# play a noise, then queue_free.
		self.hide()
		$AudioStreamPlayer.play()
		$Button.disabled = true
		await $AudioStreamPlayer.finished
		queue_free() # we bought the building, the purchase button is no longer required.
		
