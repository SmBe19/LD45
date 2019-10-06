extends Control

func _on_ok_pressed():
	$"/root/Root".personname = $margin/vbox/margin/hbox/name.text
	$"/root/Root".update_namelabels()
	$"/root/Root/audio/click".play()
	hide()
