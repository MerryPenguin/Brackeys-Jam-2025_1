extends Node


func dir_contents(path : String):
	var files = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				#print("Found file: " + file_name)
				files.push_back(path.path_join(file_name))
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return files


func find_closest_node(node_list, location):
	var closest_dist_sq = INF
	var closest_node
	for node in node_list:
		var dist_sq = node.global_position.distance_squared_to(location)
		if dist_sq < closest_dist_sq:
			closest_node = node
			closest_dist_sq = dist_sq
	return closest_node

func lookup_value(product_idx) -> int:
		var product_recipe : ProductWidgetRecipe = Globals.product_recipes[product_idx]
		var sale_price = product_recipe.default_sale_price
		if Globals.products_in_demand.has(product_idx):
			sale_price *= 2.0
		return sale_price

	
func lookup_value_by_name(product_name : String):
	for product_num in Globals.products.values():
		var product_recipe : ProductWidgetRecipe = Globals.product_recipes[product_num]
		if product_recipe.product_name == product_name:
			return lookup_value(product_num)
			
	
		
