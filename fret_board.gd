extends Node2D

var note_names = [	"R",
					"m2", "M2", "m3", "M3", 
					"P4", [ "A4", "d5" ], "P5",
					"m6", "M6", "m7", "M7" ]

var ionian = "WWHWWWH"
var ionian_shapes = [[0,0,7],[0,1,2],[0,0,3],[0,1,5],[0,1,6]]
var current_shape = 0
@onready var strings = [
	$Control/Strings/LEFrets,
	$Control/Strings/AFrets,
	$Control/Strings/GFrets,
	$Control/Strings/DFrets,
	$Control/Strings/BFrets,
	$Control/Strings/HEFrets
	]
	
const num_frets = 5
const num_strings = 6
# Called when the node enters the scene tree for the first time.
func _ready():
	make_scale(ionian, ionian_shapes[current_shape])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _unhandled_input(event):
	if event.is_action_pressed("ui_up"):
		current_shape= (current_shape+1)%ionian_shapes.size()
		make_scale(ionian, ionian_shapes[current_shape])
	if event.is_action_pressed("ui_down"):
		current_shape= (current_shape-1)%ionian_shapes.size()
		make_scale(ionian, ionian_shapes[current_shape])
		

func make_scale(intervals: String, shape):
	for string in strings:
		for fret in string.get_children():
			fret.disabled=false
	# Iterate towards High E
	var offsets = step_to_offset(intervals)
	var start = shape[1]
	var offset = (offsets[shape[2]-1]-1)%12
	for string in range(shape[0],num_strings):
		for fret in range(start,num_frets):
			var button = strings[string].get_child(fret)
			offset=(offset+1)%12
			if (offset != 6):
				button.text = note_names[offset]
			elif 6 in offsets and offsets[3]==6:
				button.text = note_names[offset][0]
			else:
				button.text = note_names[offset][1]
			if string == 3 and fret==num_frets-1:
				offset=(offset-1)%12
				continue
			if offset in offsets:
				button.disabled = true
		start = 0
	# Iterate towards Low E
	
func step_to_offset(intervals: String):
	var offsets = [0]
	for ch in intervals:
		var next = offsets.back()+1
		if ch == "W":
			next+=1
		offsets.push_back(next)
	return offsets
