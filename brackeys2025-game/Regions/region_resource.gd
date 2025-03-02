class_name Region extends Resource

@export var short_name : StringName = ""
@export_multiline var description : String = ""

@export var price_adjustments : Dictionary[Globals.products, float] = {
	Globals.products.ANXIETY : 1.0,
	Globals.products.ARTIFACT : 1.0,
	Globals.products.ASH : 1.0,
	Globals.products.BANANA : 1.0,
	Globals.products.EPISTEMOLOGY : 1.0,
	Globals.products.FRUITPHONE : 1.0,
	Globals.products.GEARS : 1.0,
	Globals.products.GRENADE : 1.0,
	Globals.products.GUNPOWDER : 1.0,
	Globals.products.HOPES : 1.0,
	Globals.products.PACIFIER : 1.0,
	Globals.products.PARADOX : 1.0,
	Globals.products.PINEAPPLE : 1.0,
	Globals.products.RAYGUN : 1.0,
	Globals.products.SINGULARITY: 1.0,
	Globals.products.SPRINGS : 1.0,
	Globals.products.STARCH : 1.0,
}

@export var contraband : Array[Globals.products] = [] # Forbidden prodcuts

func get_law_abiding_products() -> Array:
	var valid_products = Globals.products.values()
	for forbidden_product in contraband:
		valid_products.erase(forbidden_product)
	return valid_products

func pick_random_product(law_abiding : bool):
	var weights_dict = price_adjustments.duplicate()
	if law_abiding:
		for forbidden_product in contraband:
			weights_dict[forbidden_product] = 0.0
	return weighted_random_choice(weights_dict)

# Function to pick a key randomly with weighted probabilities
func weighted_random_choice(dictionary: Dictionary):
	var total_weight = 0.0
	for key in dictionary.keys():
		total_weight += dictionary[key]
	
	var random_value = randf_range(0.0, total_weight)
	for key in dictionary.keys():
		if random_value < dictionary[key]:
			return key
		random_value -= dictionary[key]
	
	return null  # Should never reach here if dictionary is not empty

	
