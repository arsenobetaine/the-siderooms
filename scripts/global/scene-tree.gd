extends Node

func print_scene_tree(node: Node, indent: String = ""):
	print(indent + "Node: " + node.name + " | Path: " + str(node.get_path()))
	for child in node.get_children():
		print_scene_tree(child, indent + "  ")

func _ready():
	print("=== Scene Tree ===")
	var root = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
	print_scene_tree(root)
