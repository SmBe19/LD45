extends Control

func _on_cancel_pressed():
	$popup.hide()
	$"/root/Root/audio/cancel".play()

func _on_localad_pressed():
	$"/root/Root".local_ad(100, 1)
	$popup.hide()

func _on_localad2_pressed():
	$"/root/Root".local_ad(500, 7)
	$popup.hide()

func _on_nationalad_pressed():
	$"/root/Root".national_ad(2000, 7)
	$popup.hide()

func _on_nationalad2_pressed():
	$"/root/Root".national_ad(5000, 17)
	$popup.hide()
