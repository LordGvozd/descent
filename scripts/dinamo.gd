extends Node2D

@export var consumption_delay = 3
@export var consumption_value = 3
@export var energy_recover = 2
@export var max_energy = 10

@export var energy = 10


func _ready() -> void:
	$Timer.start(consumption_delay)
	
func _update() -> void:
	Bus.create_event(DinamoEnergyEvent.new(energy))
	print(energy)



func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("dinamo"):
		energy += energy_recover
		if energy > max_energy: energy = max_energy
		_update()


func _on_timer_timeout() -> void:
	energy -= consumption_value
	
	if energy < 0: energy = 0
	
	_update()
