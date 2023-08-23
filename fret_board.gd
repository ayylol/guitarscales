extends Node2D

var note_names = [	"R",
					"m2", "M2", "m3", "M3", 
					"P4", [ "A4", "d5" ], "P5",
					"m6", "M6", "m7", "M7" ]

var modes = ["Ionian", "Dorian", "Phrygian", "Lydian",
			"Mixolydian", "Aeolian", "Locrian"]

var ionian = "WWHWWWH"
# String, Fret, Note
var shapes =[[0,0,6],[0,1,1],[0,0,2],[0,1,4],[0,1,5]]
var current_mode = 0
var shape_index = 0
var current_shape = shapes[shape_index]
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
const num_modes = 7
# Called when the node enters the scene tree for the first time.
func _ready():
	make_scale(step_to_offset(ionian), current_shape)
	$ModeLabel.text = modes[current_mode]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _unhandled_input(event):
	var changed = false
	if event.is_action_pressed("ui_up"):
		changed = true
		shape_index= (shape_index+1)%shapes.size()
	if event.is_action_pressed("ui_down"):
		changed = true
		shape_index= (shape_index-1)%shapes.size()
	if event.is_action_pressed("ui_right"):
		changed = true
		current_mode = (current_mode+1)%num_modes
	if event.is_action_pressed("ui_left"):
		changed = true
		current_mode = posmod((current_mode-1),num_modes)
	if changed:
		current_shape = shapes[shape_index].duplicate()
		current_shape[2] = posmod(current_shape[2]-current_mode,num_modes)
		make_scale(step_to_offset(ionian, current_mode), current_shape)
		$ModeLabel.text = modes[current_mode]
		

func make_scale(offsets, shape):
	for string in strings:
		for fret in string.get_children():
			fret.disabled=false
	# Iterate towards High E
	var start = shape[1]
	var offset = (offsets[shape[2]]-1)%12
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
				if not (fret == 4 and string == 3):
					button.disabled = true
		start = 0
	# Iterate towards Low E
	start = shape[1]-1
	offset = posmod(offsets[shape[2]],12)
	for string in range(shape[0],-1,-1):
		for fret in range(start,-1,-1):
			var button = strings[string].get_child(fret)
			offset=posmod(offset-1,12)
			if (offset != 6):
				button.text = note_names[offset]
			elif 6 in offsets and offsets[3]==6:
				button.text = note_names[offset][0]
			else:
				button.text = note_names[offset][1]
			if string == 4 and fret==0:
				offset=(offset+1)%12
				continue
			if offset in offsets:
				if not (fret == 4 and string == 3):
					button.disabled = true
		start = num_frets-1
	
func step_to_offset(intervals: String, start: int = 0):
	var offsets = [0]
	var indexes = range(start,intervals.length())
	indexes.append_array(range(0,start))
	for i in indexes:
		var ch = intervals[i]
		var next = offsets.back()+1
		if ch == "W":
			next+=1
		offsets.push_back(next)
	return offsets
