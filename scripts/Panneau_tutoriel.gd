extends Control

func init(texte, image):
	$Contenant_Panneau/Panneau/VBoxContainer/RichTextLabel.text = texte
	$Contenant_Panneau/Panneau/VBoxContainer/TextureRect.texture = load(image)

func _on_Area2D_body_entered(body):
	if body.is_in_group("Joueur"):
		$Contenant_Panneau/AnimationPlayer.play("Entree")

func _on_Area2D_body_exited(body):
	if body.is_in_group("Joueur"):
		$Contenant_Panneau/AnimationPlayer.play_backwards("Entree")
