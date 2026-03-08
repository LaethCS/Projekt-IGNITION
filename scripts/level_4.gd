extends BaseLevel

func _ready():
	gold_time = 7.0
	silver_time = 12.0
	super()

# Hier bestrafen wir die Tode:
func _calculate_rating(time: float) -> String:
	var deaths = GlobalStats.deaths_in_current_level
	var penalty_time = time + (deaths * 10.0)
	
	if penalty_time <= gold_time:
		return "S (Brandschutz-Meister)"
	elif penalty_time <= silver_time:
		return "A (Sehr gut)"
	elif penalty_time <= 15.0:
		return "B (Gut - Vorsicht vor dem Feuer!)"
	else: 
		return "C (Bestanden - Achte auf \nden Sicherheitsabstand)"
