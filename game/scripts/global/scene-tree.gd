class_name SceneTreePrinter
extends Node

func print_scene_tree(node: Node, indent: String = "") -> void:
	print(indent + "Node: " + node.name + " | Path: " + str(node.get_path()))
	for child in node.get_children():
		print_scene_tree(child, indent + "  ")

func _ready() -> void:
	var root = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
	print_scene_tree(root)
