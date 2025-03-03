@tool
extends Control



@export var NoteTitle : String:
	set(v):
		%NoteTitle.text = v
		NoteTitle = v
	get:
		return NoteTitle
		
@export_multiline var NoteText : String:
	set(v):
		%NoteText.text = v
		NoteText = v
	get:
		return NoteText

func _ready():
	if Engine.is_editor_hint():
		# in editor
		if NoteTitle == null:
			NoteTitle = self.name
		%NoteText.text = NoteText
	else: # in-game
		hide()
		
