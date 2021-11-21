extends Control

func _ready():
	$AnimationPlayer.play("appartition")

func _on_AnimationPlayer_animation_finished(anim_name="apparition"):
	get_tree().reload_current_scene()
