extends CSGBox3D

var dir := true


func _ready() -> void:
	_tween_start()
	

func animate(tween: Tween) -> void:
	var target_y := 0.0;
	if dir:
		target_y = 0.2
		
	dir = !dir
	
	print(target_y)
	tween.tween_property(self, "position", Vector3(0, target_y, 0), 1.5)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(Callable(self, "_tween_start"))

func _tween_start() -> void:
	var tween = create_tween()
	animate(tween)
