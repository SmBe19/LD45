extends Node2D

var active_city: int

func show():
	visible = true
	set_city($"/root/Root".current_city)

func set_city(city: int):
	var citybutton: TextureButton = $citybuttons.get_children()[active_city]
	citybutton.texture_normal = null
	active_city = city
	citybutton = $citybuttons.get_children()[active_city]
	citybutton.texture_normal = citybutton.texture_hover
	set_labels()

func set_labels():
	var cityinfo: City = $"/root/Root".cities[active_city]
	$cityinfo/vbox/cityname.text = cityinfo.name
	$cityinfo/vbox/population.text = str("People: ", cityinfo.population)
	$cityinfo/vbox/popularity.text = str("Popularity: ", cityinfo.public_popularity, "%")
	$cityinfo/vbox/voters.text = str("Voters: ", cityinfo.public_voters)
	$cityinfo/vbox/poll.text = str("(", int(round($"/root/Root".last_poll)), " s ago)")
	$cityinfo/vbox/advertisement.text = str("Ad Effect: ", round(cityinfo.advertisement*100))
	$cityinfo/vbox/donations.text = str("Donat.: $ ", cityinfo.total_donations)
	$cityinfo/vbox/movehere.disabled = active_city == $"/root/Root".current_city or $"/root/Root".current_campaign != null

func _process(delta):
	# TODO remove
	# $"/root/Root".cities[active_city].poll()
	set_labels()

func _on_goback_pressed():
	hide()

func _on_movehere_pressed():
	$"/root/Root".move_to_city(active_city)
	hide()
