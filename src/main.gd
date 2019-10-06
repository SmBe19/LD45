extends Node2D

var personname: String
var money: int
var cities: Array
var current_city: int
var offices: Array
var current_office: Office
var current_campaign: Office
var campaign_time: float
var last_poll: float

func _ready():
	personname = "Mr Blub"
	money = 1000
	cities = []
	offices = []
	
	var current_population: int = 970
	for cityname in ["Fort Eariio", "West Pointsmi", "Ombrim", "Noyeo", "Skelmode"]:
		var new_city = City.new()
		new_city.initvals(cityname, current_population)
		var influence = 12
		for officename in ["Parliament Memb.", "Vegetables Minister", "Major"]:
			var new_office = Office.new()
			new_office.initvals(cityname + " " + officename, new_city, int(influence))
			new_city.offices.append(new_office)
			influence *= 2.5
		cities.append(new_city)
		current_population = int(current_population * 0.7)
	
	cities[0].neighbors.append(cities[2]) # Fort Eariio, Ombrim
	cities[2].neighbors.append(cities[0]) # Fort Eariio, Ombrim
	cities[2].neighbors.append(cities[3]) # Ombrim, Noyeo
	cities[3].neighbors.append(cities[2]) # Ombrim, Noyeo
	cities[3].neighbors.append(cities[1]) # Noyeo, West Pointsmi
	cities[1].neighbors.append(cities[3]) # Noyeo, West Pointsmi
	cities[1].neighbors.append(cities[4]) # West Pointsmi, Skelmode
	cities[4].neighbors.append(cities[1]) # West Pointsmi, Skelmode
	current_city = 3
	cities[current_city].is_hometown = true
	
	var current_influence = 100
	for officename in ["National Parliament Memb.", "Dinosaur Minister", "President"]:
		var new_office = Office.new()
		new_office.initvals(officename, null, current_influence)
		offices.append(new_office)
		current_influence *= 2
	
	update_namelabels()
	prepare_campaign_popup()
	$intro.show()

func update_namelabels():
	$personname.text = personname
	$officename.text = current_office.name if current_office != null else "Nobody"
	$cityname.text = cities[current_city].name

func _process(delta):
	for city in cities:
		city.update(delta, offices, current_campaign)
		money += city.get_donations(delta)
	if current_campaign != null:
		campaign_time -= delta
		if campaign_time < 0:
			finish_campaign()
		$campaigninfo/campaigntime.text = str(round(campaign_time), " s")
	last_poll += delta
	$money.text = str("$ ", money)

func get_voters():
	var voters = 0
	var total = 0
	if current_campaign.city == null:
		for city in cities:
			voters += int(round(city.voters * city.population))
			total += city.population
	else:
		voters += int(round(current_campaign.city.voters * current_campaign.city.population))
		total += current_campaign.city.population
	return [voters, total]

func finish_campaign():
	$campaigninfo/campaigntime.hide()
	$"/root/Root/audio/waitmusic".set_stream_paused(false)
	var res = get_voters()
	if res[0]*2 > res[1]:
		$"/root/Root/audio/win".play()
		if current_office != null:
			if current_office.city == current_campaign.city:
				current_office.is_held = false
		current_office = current_campaign
		current_office.is_held = true
		update_namelabels()
		$campaignresultpopup/margin/vbox/label.text = str("Congratulations, you won the election. You are now ", current_office.name, "! You had ", res[0], " votes out of a total of ", res[1], ".")
	else:
		$"/root/Root/audio/lose".play()
		$campaignresultpopup/margin/vbox/label.text = str("You lost the election! You had ", res[0], " votes out of a total of ", res[1], ".")
	publish_poll()
	current_campaign = null
	$campaigninfo/officename.text = "---"
	$campaignresultpopup.popup_centered()
	prepare_campaign_popup()
	$campaigninfo/startrun.text = "start"
	$campaigninfo/startrun.show()

func prepare_campaign_popup():
	for child in $campaignpopup/vbox.get_children():
		child.queue_free()
	var local_influence = 0
	for office in cities[current_city].offices:
		if office.is_held:
			local_influence = max(local_influence, office.influence)
	var global_influence = 0
	for office in offices:
		if office.is_held:
			global_influence = max(global_influence, office.influence)
	for office in cities[current_city].offices:
		if office.influence <= local_influence:
			continue
		var button = Button.new()
		button.text = office.name
		button.connect("pressed", self, "start_campaign", [office])
		$campaignpopup/vbox.add_child(button)
	for office in offices:
		if office.influence <= global_influence:
			continue
		var button = Button.new()
		button.text = office.name
		button.connect("pressed", self, "start_campaign", [office])
		$campaignpopup/vbox.add_child(button)
	var cancelbutton = Button.new()
	cancelbutton.text = "cancel"
	cancelbutton.connect("pressed", self, "cancel_start_campaign")
	$campaignpopup/vbox.add_child(cancelbutton)

func start_campaign(office: Office):
	current_campaign = office
	$campaigninfo/officename.text = office.name
	campaign_time = 120
	$campaigninfo/campaigntime.show()
	$campaigninfo/startrun.show()
	$campaigninfo/startrun.text = "Vote Now"
	$campaignpopup.hide()
	for city in cities:
		city.voters = 0.0
		city.poll()
	last_poll = 0
	$pollinfo.show()
	$pollinfo.set_poll(0, 2, 1)
	$"/root/Root/audio/sendtweet".play()
	$"/root/Root/audio/waitmusic".set_stream_paused(true)
	$"/root/Root/audio/electionmusic".play()

func cancel_start_campaign():
	$campaignpopup.hide()
	$campaigninfo/startrun.show()
	$"/root/Root/audio/cancel".play()

func _on_startrun_pressed():
	if current_campaign == null:
		$campaigninfo/startrun.hide()
		$campaignpopup.show()
		$campaignpopup.hide()
		$campaignpopup.popup_centered()
		$"/root/Root/audio/click".play()
	else:
		campaign_time = 1
		$"/root/Root/audio/click".play()
		$"/root/Root/audio/electionmusic".stop()

func _on_resultokbutton_pressed():
	$campaignresultpopup.hide()
	$"/root/Root/audio/click".play()

func publish_poll():
	last_poll = 0
	for city in cities:
		city.poll()
	if current_campaign == null:
		$pollinfo.hide()
		return
	var res = get_voters()
	var op1
	var op2
	if res[0] * 2 > res[1]:
		if res[0] < res[1]:
			op1 = randi() % (res[1] - res[0])
		else:
			op1 = 0
	else:
		op1 = res[0] + randi() % (res[1] - 2*res[0])
	op2 = res[1] - res[0] - op1
	$pollinfo.set_poll(res[0], op1, op2)

func _on_newpoll_pressed():
	if money >= 20:
		money -= 20
		$"/root/Root/audio/sendtweet".play()
		publish_poll()
	else:
		$"/root/Root/audio/nope".play()

func _on_financeinfo_pressed():
	$finance/popup.popup_centered()
	$"/root/Root/audio/click".play()

func local_ad(price, multiplier):
	if money >= price:
		money -= price
		cities[current_city].advertisement += multiplier
		$"/root/Root/audio/sendtweet".play()
	else:
		$"/root/Root/audio/nope".play()

func national_ad(price, multiplier):
	if money >= price:
		money -= price
		for city in cities:
			city.advertisement += multiplier
		$"/root/Root/audio/sendtweet".play()
	else:
		$"/root/Root/audio/nope".play()

func _on_newtweet_pressed():
	$tweet/popup.popup_centered()
	$"/root/Root/audio/click".play()

func move_to_city(city):
	if current_city != city:
		if current_office != null and current_office.city != null:
			current_office = null
		if current_office == null:
			for office in cities[city].offices:
				if office.is_held:
					current_office = office
		cities[current_city].is_hometown = false
		current_city = city
		cities[current_city].is_hometown = true
		update_namelabels()
		prepare_campaign_popup()

func _on_outrotimer_timeout():
	$outro.show_outro(personname)

func _on_campaignresultpopup_popup_hide():
	if current_office != null and current_office.name == "President":
		$outrotimer.start()

func _on_sound_toggled(button_pressed):
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Effects"), button_pressed)

func _on_music_toggled(button_pressed):
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), button_pressed)
