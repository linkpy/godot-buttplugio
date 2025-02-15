@tool
extends EditorPlugin



func _enter_tree() -> void:
	add_custom_type(
		"BPIOClient", "Node",
		preload("res://addons/buttplugio/client.gd"),
		preload("res://addons/buttplugio/bpioclient.svg")
	)

func _exit_tree() -> void:
	remove_custom_type("BPIOClient")
