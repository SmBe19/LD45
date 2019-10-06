extends PanelContainer

func show_outro(name):
	$margin/vbox/Label.text = str("Congratulations, ", name, "!")
	show()