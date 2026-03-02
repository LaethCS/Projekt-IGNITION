extends Area3D

# Wir brauchen keine export Variable mehr für die Richtung,
# weil wir jetzt die echte Rotation des Objekts benutzen!
var wind_direction: Vector3

func _ready():
	# HIER IST DER TRICK:
	# "global_transform.basis.z" ist der Vektor, der nach HINTEN zeigt (aus dem Objekt raus).
	# "-global_transform.basis.z" ist der Vektor, der nach VORNE zeigt.
	
	wind_direction = -global_transform.basis.z.normalized()
	
	print("WindZone initialisiert. Richtung: ", wind_direction)
