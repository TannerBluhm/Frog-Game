extends Control

onready var numerator = $Numerator
onready var denominator = $Denominator

func _ready():
	add_to_group(Strings.FLY_COUNTERS_GROUP_ID)
