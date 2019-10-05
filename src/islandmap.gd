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
	var cityinfo: City = $"/root/Root".cities[active_city]
	$cityinfo/vbox/cityname.text = cityinfo.name
	$cityinfo/vbox/population.text = str("Pop: ", cityinfo.population)
	$cityinfo/vbox/voters.text = str("Voters: ", cityinfo.voters)


func _on_goback_pressed():
	visible = false
