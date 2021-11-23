extends Control

func _ready():
	$AnimationPlayer.play("appartition")

# warning-ignore:unused_argument
func _on_AnimationPlayer_animation_finished(anim_name="apparition"):
# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()
