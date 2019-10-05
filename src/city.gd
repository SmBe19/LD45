class_name City

var name: String
var population: int
var popularity: float
var advertisement: float
var voters: float
var offices: Array
var neighbors: Array
var is_hometown: bool
var public_popularity: int
var public_voters: int
var donations: float

func initvals(name: String, population: int):
	self.name = name
	self.population = population
	self.popularity = 0
	self.voters = 0
	self.offices = []
	self.neighbors = []
	self.is_hometown = false
	self.donations = 0

func update(delta: float, global_offices: Array, current_campaign):
	if not is_hometown:
		self.popularity *= pow(0.99, delta)
	else:
		for office in offices:
			if office.is_held:
				self.popularity += delta * office.influence / 10000.0
	for office in global_offices:
		if office.is_held:
			self.popularity += delta * office.influence / 10000.0
	for neighbor in neighbors:
		if neighbor.popularity > 0.6:
			popularity += delta * (log(neighbor.popularity+0.01)-log(0.01)) / 5000.0 * neighbor.population / population
	popularity += delta * pow(advertisement, 1.05) / 250.0
	advertisement = max(0, advertisement - delta / 10.0)
	popularity = clamp(popularity, 0, 1)
	
	if current_campaign != null and (current_campaign.city == null or current_campaign.city == self):
		if popularity > 0.3:
			voters += delta * pow(popularity + advertisement/5.0, 2) / current_campaign.influence / 5.0
		else:
			voters -= delta * (1-(popularity + advertisement/5.0)) / 1000.0
		voters = clamp(voters, 0, 1)

func poll():
	public_popularity = int(round(popularity*100))
	public_voters = int(round(population * voters))

func get_donations(delta):
	donations += delta * pow(popularity, 1.2) * 2
	var res = int(floor(donations))
	donations -= res
	return res