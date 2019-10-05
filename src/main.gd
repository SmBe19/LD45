extends Node2D

var personname: String
var officename: String
var cities: Array
var current_city: int

func _ready():
	personname = "Mr Blub"
	officename = "Nobody"
	cities = []
	var current_population: int = 1024
	for cityname in ["Fort Eariio", "West Pointsmi", "Ombrim", "Noyeo", "Skelmode"]:
		var new_city = City.new()
		new_city.initvals(cityname, current_population)
		cities.append(new_city)
		current_population /= 2
	current_city = 1

func update_labels():
	$personname.text = personname
	$officename.text = officename
