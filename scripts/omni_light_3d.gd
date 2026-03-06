extends OmniLight3D

func _process(delta):
	$Visuals/OmniLight3D.light_energy = 3.0 + randf() * 0.5
