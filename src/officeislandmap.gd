extends Sprite

var orig_scale: Vector2

func _ready():
	orig_scale = scale

func _on_Button_mouse_entered():
	scale = orig_scale * 1.05

func _on_Button_mouse_exited():
	scale = orig_scale
