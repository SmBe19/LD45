class_name City

var name: String
var population: int # const
var popularity: float # in [1, 100]
var advertisement: float # in [0, \infty[
var voters: float # in [0, pop]
var is_hometown: bool
var offices: Array
var neighbors: Array
var public_popularity: int # for map, log(pop, 10)
var public_voters: int # for map, voters
var donations: float # unspent donations
var total_donations: int # total paid donations
var current_office

func initvals(name: String, population: int):
	self.name = name
	self.population = population
	self.popularity = 1
	self.voters = 0
	self.offices = []
	self.neighbors = []
	self.is_hometown = false
	self.donations = 0
	self.current_office = null
	self.total_donations = 0

func log_popularity():
	return log(popularity)/log(10)

func update(delta: float, global_offices: Array, current_campaign):
	var old_influence = 0
	for office in offices:
		if office.is_held:
			old_influence += office.influence
	for office in global_offices:
		if office.is_held:
			old_influence += office.influence

	# Popularity Decay
	if not is_hometown:
		popularity *= pow(0.997, delta)

	# Popularity from Office
	popularity += delta * old_influence / 7000.0

	# Popularity Spread
	for neighbor in neighbors:
		if neighbor.log_popularity() > 0.7:
			popularity += delta * (log(neighbor.log_popularity()+0.01)-log(0.01)) / 250.0 * neighbor.population / population

	# Advertisement
	popularity += delta * pow(advertisement * 128 / population, 0.4) / 40.0
	advertisement = max(0, advertisement - max(1, advertisement) * delta / 10.0)

	# Popularity Clamp
	popularity = clamp(popularity, 1, 100)

	# Voters
	if current_campaign != null and (current_campaign.city == null or current_campaign.city == self):
		var difficulty = pow(max(1, current_campaign.influence - old_influence), 2)
		voters += delta * pow(log_popularity(), 2) * 10 / difficulty
		voters += delta * pow(advertisement * 128 / population, 1/4.0) * 0.75 / difficulty
		# TODO remove
		voters += delta
		voters = clamp(voters, 0, 1)

func poll():
	public_popularity = int(round(log_popularity()*100))
	public_voters = int(round(population * voters))

func get_donations(delta):
	donations += delta * pow(log_popularity(), 1.5) * 5
	var res = int(floor(donations))
	donations -= res
	total_donations += res
	return res