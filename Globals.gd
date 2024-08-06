extends Node


var ready_to_coll = false
var disable_coll = false

func _process(delta):
	if disable_coll:
		ready_to_coll = false
		disable_coll = false
	
	if ready_to_coll:
		disable_coll = true
