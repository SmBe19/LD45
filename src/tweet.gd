extends Control

var good = ["good", "amazing", "awesome", "excellent", "faboulous", "fantastic", "gorgeous", "incredible", "outstanding", "perfect", "remarkable", "splendid", "stellar"]
var bad = ["bad", "sad", "afraid", "annoyed", "awkward", "despicable", "enraged", "frustrated", "greedy", "grumpy", "ignorant", "incapable", "ignorant", "lousy", "miserable", "mean", "naive", "outrageous", "outrage", "pathetic", "stupid", "useless", "weak"]
var last_tweet = []

func _on_cancel_pressed():
	$popup.hide()
	$"/root/Root/audio/cancel".play()

func handle_city(city, value, inside):
	var current_campaign = $"/root/Root".current_campaign
	var campaign = current_campaign != null and (current_campaign.city == city or current_campaign.city == null)
	var old_pop = city.popularity
	if value > 2:
		if inside:
			city.advertisement += 2
	elif value < 0:
		if inside:
			city.advertisement = 0.0
			city.popularity *= pow(2, value)
			if campaign:
				city.voters *= pow(2, value*0.2)
		else:
			city.popularity *= pow(2, value*0.3)
	if value > 0:
		if inside:
			city.popularity += min(1, (pow(2, value) - 1) / 16.0)
			if campaign:
				city.voters += min(1, (pow(2, value*0.4) - 1) / 32.0)
		else:
			city.popularity += min(1, (pow(2, value*0.3) - 1) / 16.0)
	return city.popularity - old_pop

func _on_send_pressed():
	var text = $popup/margin/vbox/tweet.text.to_lower()
	var cities = $"/root/Root".cities
	var value = 0.5
	var done = []
	for part in text.replace(".", "").replace(",", "").replace("!", "").replace("?", "").split(" "):
		if part in done:
			continue
		done.append(part)
		if part in last_tweet:
			continue
		if part in good:
			value += 0.5
		elif part in bad:
			value -= 0.75
	last_tweet = done
	if "mariama" in text:
		value *= 1.5
	var result = ""
	for city in cities:
		var res = handle_city(city, value + (randf() - 0.5) * 5, city.name.to_lower() in text)
		result += str(city.name, ": ")
		if res < -0.5:
			result += "--"
		elif res < -0.1:
			result += "-"
		elif res < 0.1:
			result += "="
		elif res < 0.5:
			result += "+"
		else:
			result += "++"
		result += "\n"
	$resultpopup/margin/vbox/result.text = result
	$popup.hide()
	$resultpopup.show()
	$resultpopup.hide()
	$resultpopup.popup_centered()
	$"/root/Root/audio/sendtweet".play()

func _on_popup_about_to_show():
	$popup/margin/vbox/tweet.text = ""
	$popup/margin/vbox/hbox/length.text = str("0/140")

func _on_tweet_text_changed():
	var length = $popup/margin/vbox/tweet.text.length()
	$popup/margin/vbox/hbox/length.text = str(length, "/140")
	$popup/margin/vbox/hbox/send.disabled = length > 140
	$"/root/Root/audio/tweettype".play()

func _on_ok_pressed():
	$resultpopup.hide()
	$"/root/Root/audio/click".play()
