extends Particles2D

# Called when the node enters the scene tree for the first time.
func _ready():
	self.emitting = true

func _on_Timer_timeout():
	queue_free()

func scale_to(scaling):
	self.scale.x = scaling
	self.scale.y = scaling
