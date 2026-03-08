extends CanvasLayer

@onready var label = $PanelContainer/MarginContainer/Label

var lines = []
var index = 0

func _ready():
	hide()

func start(new_lines):

	lines = new_lines
	index = 0
	show()
	label.text = lines[index]


func _input(event):
	if event.is_action_pressed("interact"):

		index += 1
		
		if index >= lines.size():
			hide()
			return
		
		label.text = lines[index]
