extends Particles2D
class_name Particles2D_Plus, "res://Particles2D+/GPUParticles2D_Icon.svg"


export var one_shot_start: bool = false

var emitting_internal: bool
var timer: Timer

signal particles_cycle_finished


func _ready():
	timer = Timer.new()
# warning-ignore:return_value_discarded
	timer.connect("timeout", self, "_on_timer_timeout")
	add_child(timer)
	configure_timer()
	
	if one_shot_start:
		one_shot = true
		emitting = true
	
	emitting_internal = one_shot

func configure_timer():
	timer.autostart = emitting
	timer.one_shot = one_shot
	timer.wait_time = lifetime / float(speed_scale)
	timer.paused = true
	
	if preprocess != 0 and !emitting_internal: # SET TIMER TO REFLECT PREPROCESS IF !one_shot
		emitting_internal = true
		if preprocess < lifetime:
			timer.start(lifetime - preprocess)
		else: # PREPROCESS IS > LIFETIME EDGE CASE
			timer.start(lifetime - fposmod(preprocess, lifetime))
	else:
		timer.start()
	
	if emitting:
		timer.paused = false # UNPAUSES/STARTS THE TIMER IF EMITTING IS TRUE


func _process(_delta):
	match one_shot:
		
		true:  # USE **PROCESS** TO DETERMINE SIGNAL EMIT POINT
			if !emitting and emitting_internal:
				emitting_internal = false
				emit_signal("particles_cycle_finished")
			if emitting and !emitting_internal:
				emitting_internal = true
		
		false: # USE **TIMER** TO DETERMINE SIGNAL EMIT POINT
			if emitting and !timer.autostart: # CHECKS IF USER SETS EMITTING TRUE AT RUNTIME
				emitting_internal = false
				configure_timer()


func _on_timer_timeout():
	if !one_shot:
		configure_timer()
		emit_signal("particles_cycle_finished")
