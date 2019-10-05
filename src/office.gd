class_name Office

var name: String
var city: City
var influence: int
var is_held: bool

func initvals(name: String, city: City, influence: int):
	self.name = name
	self.city = city
	self.influence = influence
	self.is_held = false