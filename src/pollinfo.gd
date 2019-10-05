extends Control

func set_poll(hero, op1, op2):
	var total = hero + op1 + op2
	$vbox/hero/center/result.value = hero * 100 / total
	$vbox/opponent1/center/result.value = op1 * 100 / total
	$vbox/opponent2/center/result.value = op2 * 100 / total
	if hero > op1 and hero > op2:
		$vbox.move_child($vbox/hero, 0)
		if op1 > op2:
			$vbox.move_child($vbox/opponent1, 1)
		else:
			$vbox.move_child($vbox/opponent2, 1)
	elif op1 > hero and op1 > op2:
		$vbox.move_child($vbox/opponent1, 0)
		if hero > op2:
			$vbox.move_child($vbox/hero, 1)
		else:
			$vbox.move_child($vbox/opponent2, 1)
	else:
		$vbox.move_child($vbox/opponent2, 0)
		if hero > op1:
			$vbox.move_child($vbox/hero, 1)
		else:
			$vbox.move_child($vbox/opponent1, 1)

func _process(delta):
	$vbox/lastpoll.text = str("(", int(round($"/root/Root".last_poll)), " s ago)")