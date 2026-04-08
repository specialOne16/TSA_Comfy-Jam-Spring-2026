extends Node2D

@onready var gate_field: GateField = $GateField
@onready var inspection: Inspection = $Inspection

func _ready() -> void:
	gate_field.inspect.connect(inspection.inspect)
