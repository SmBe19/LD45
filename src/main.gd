extends Node2D

var personname: String
var officename: String
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
	officename = "Nobody"
	money = 1000
	cities = []
	offices = []
	
	var current_population: int = 1024
	for cityname in ["Fort Eariio", "West Pointsmi", "Ombrim", "Noyeo", "Skelmode"]:
		var new_city = City.new()
		new_city.initvals(cityname, current_population)
		var influence = 12
		for officename in ["Memb. Parliament", "Vegetables Minister", "Major"]:
			var new_office = Office.new()
			new_office.initvals(cityname + " " + officename, new_city, int(influence))
			new_city.offices.append(new_office)
			influence *= 2.5
		cities.append(new_city)
		current_population /= 2
	
	cities[0].neighbors.append(cities[2]) # Fort Eariio, Ombrim
	cities[2].neighbors.append(cities[0]) # Fort Eariio, Ombrim
	cities[2].neighbors.append(cities[3]) # Ombrim, Noyeo
	cities[3].neighbors.append(cities[2]) # Ombrim, Noyeo
	cities[3].neighbors.append(cities[1]) # Noyeo, West Pointsmi
	cities[1].neighbors.append(cities[3]) # Noyeo, West Pointsmi
	cities[1].neighbors.append(cities[4]) # West Pointsmi, Skelmode
	cities[4].neighbors.append(cities[1]) # West Pointsmi, Skelmode
	current_city = 1
	cities[current_city].is_hometown = true
	
	var current_influence = 25
	for officename in ["Memb. National Parliament", "Dinosaur Minister", "President"]:
		var new_office = Office.new()
		new_office.initvals(officename, null, current_influence)
		offices.append(new_office)
		current_influence *= 2
	
	update_namelabels()
	prepare_campaign_popup()

func update_namelabels():
	$personname.text = personname
	$officename.text = officename

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
	var res = get_voters()
	if res[0]*2 > res[1]:
		if current_office != null:
			current_office.is_held = false
		current_office = current_campaign
		current_office.is_held = true
		officename = current_office.name
		update_namelabels()
		$campaignresultpopup/margin/vbox/label.text = str("Congratulations, you won the election. You are now ", current_office.name, "! You had ", res[0], " votes out of a total of ", res[1], ".")
	else:
		$campaignresultpopup/margin/vbox/label.text = str("You lost the election! You had ", res[0], " votes out of a total of ", res[1], ".")
	publish_poll()
	current_campaign = null
	$campaigninfo/officename.text = "---"
	$campaignresultpopup.popup_centered()
	prepare_campaign_popup()
	$campaigninfo/startrun.show()

func prepare_campaign_popup():
	for child in $campaignpopup/vbox.get_children():
		child.queue_free()
	for office in cities[current_city].offices:
		if office.is_held:
			continue
		var button = Button.new()
		button.text = office.name
		button.connect("pressed", self, "start_campaign", [office])
		$campaignpopup/vbox.add_child(button)
	for office in offices:
		if office.is_held:
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
	$campaigninfo/startrun.hide()
	$campaignpopup.hide()
	for city in cities:
		city.voters = 0.0
		city.poll()
	last_poll = 0
	$pollinfo.show()
	$pollinfo.set_poll(0, 2, 1)

func cancel_start_campaign():
	$campaignpopup.hide()
	$campaigninfo/startrun.show()

func _on_startrun_pressed():
	$campaigninfo/startrun.hide()
	$campaignpopup.show()
	$campaignpopup.hide()
	$campaignpopup.popup_centered()

func _on_resultokbutton_pressed():
	$campaignresultpopup.hide()

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
	if $pollinfo.visible and money >= 20:
		money -= 20
		publish_poll()

func _on_financeinfo_pressed():
	$finance/popup.popup_centered()

func local_ad(price, multiplier):
	if money >= price:
		money -= price
		cities[current_city].advertisement += multiplier

func national_ad(price, multiplier):
	if money >= price:
		money -= price
		for city in cities:
			city.advertisement += multiplier

func _on_newtweet_pressed():
	$tweet/popup.popup_centered()

func move_to_city(city):
	if current_city != city:
		if current_office != null and current_office.city != null:
			current_office = null
			officename = "Nobody"
		cities[current_city].is_hometown = false
		current_city = city
		cities[current_city].is_hometown = true
		prepare_campaign_popup()