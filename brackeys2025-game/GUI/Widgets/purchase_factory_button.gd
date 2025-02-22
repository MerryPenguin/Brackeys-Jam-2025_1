extends HBoxContainer

@export var factory_building : Globals.buildings = Globals.buildings.INORGANICS
@export var purchase_price : int = 200
@export var icon : AtlasTexture

var time_elapsed : float = 0
var polling_interval : float = 0.5 # seconds
var last_poll_time : float = 0

signal factory_unlocked()

func _ready():
	hide_if_unlocked()
	setup_button_and_text()
	factory_unlocked.connect(Globals.current_hud._on_factory_unlocked)
	factory_unlocked.connect(owner._on_factory_unlocked)
	Globals.cash_changed.connect(disable_if_insufficient_funds)

#func _process(delta):
	#time_elapsed += delta
	#if time_elapsed > last_poll_time + polling_interval:
		#disable_if_insufficient_funds(Globals.cash)

func hide_if_unlocked():
	if Globals.unlocked_buildings.has(factory_building):
		queue_free()

func disable_if_insufficient_funds(cash_available):
	if cash_available < purchase_price:
		%Button.disabled = true
	else:
		%Button.disabled = false
	
func setup_button_and_text():
	var ref_scene = Globals.building_scenes[factory_building].instantiate()
	%Button.icon = icon
	%FactoryNameLabel.text = ref_scene.short_name
	%PriceLabel.text =  "$" + str(purchase_price)
	ref_scene.queue_free()
	

func _on_button_pressed() -> void:
	if not Globals.unlocked_buildings.has(factory_building) and Globals.cash >= purchase_price:
		Globals.unlocked_buildings.push_back(factory_building)
		Globals.cash -= purchase_price
		# play a noise, then queue_free.
		factory_unlocked.emit(factory_building)
		self.hide()
		$PurchaseNoise.play()
		%Button.disabled = true
		await $PurchaseNoise.finished
		queue_free() # we bought the building, the purchase button is no longer required.
		
