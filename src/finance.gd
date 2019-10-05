extends Control

func _on_cancel_pressed():
	$popup.hide()

func _on_localad_pressed():
	$"/root/Root".local_ad(100, 1.5)
	$popup.hide()

func _on_localad2_pressed():
	$"/root/Root".local_ad(500, 4)
	$popup.hide()

func _on_nationalad_pressed():
	$"/root/Root".national_ad(2000, 3)
	$popup.hide()

func _on_nationalad2_pressed():
	$"/root/Root".national_ad(5000, 8)
	$popup.hide()
