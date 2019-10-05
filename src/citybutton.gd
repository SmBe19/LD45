extends TextureButton

signal cityclicked(index)
export var cityindex: int

func _ready():
	self.connect("pressed", self, "firecityclicked")

func firecityclicked():
	emit_signal("cityclicked", cityindex)
