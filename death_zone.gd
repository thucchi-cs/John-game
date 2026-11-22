extends Area2D



func _on_body_entered(body):
	if body.name == "CharacterBody2D":
		body.respawn()


func _on_new_level_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://ROOT2.tscn")
