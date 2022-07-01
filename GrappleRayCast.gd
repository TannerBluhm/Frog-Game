extends RayCast

onready var default_end = $DefaultTongueEnd

func _ready():
	default_end.translation = cast_to
