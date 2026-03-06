extends BaseLevel

# Hier bestrafen wir die Tode:
func _calculate_rating(time: float) -> String:
	var deaths = GlobalStats.deaths_in_current_level
	var penalty_time = time + (deaths * 10.0)
	
	if penalty_time <= 45.0:
		return "S (Brandschutz-Meister)"
	elif penalty_time <= 55.0:
		return "A (Sehr gut)"
	elif penalty_time <= 75.0:
		return "B (Gut - Vorsicht vor dem Feuer!)"
	else: 
		return "C (Bestanden - Achte auf \nden Sicherheitsabstand)"
