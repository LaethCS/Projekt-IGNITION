extends BaseLevel # Erbt von unserem neuen Mutter-Skript!

# Wir tauschen nur die Rechnung aus:
func _calculate_rating(time: float) -> String:
	var player = get_tree().root.find_child("Player", true, false)
	var blowbacks = 0
	if player and "blowback_count" in player:
		blowbacks = player.blowback_count
		
	if blowbacks == 0 and time <= gold_time:
		return "S (Brandschutz-Profi)"
	if time <= gold_time and blowbacks <= 2:
		return "A (Sehr gut)"
	elif blowbacks <= 5:
		return "B (Gut)"
	else: 
		return "C (Bestanden - Achte mehr auf den Wind)"
