class_name CustomerIdentity extends Node


@export var id : StringName

@export var sex : String
@export var education : String
@export var affiliation : String

@export var educations = [
	"MD Business\nManagement",
	"PhD Folk\nDancing",
	"MSc Cake\nDecorating",
	"BA Extreme\nIroning",
	"MFA Chainsaw\nSculpture",
	"LLB Medieval\nLaw",
	"BSc Professional\nClowning",
	"MA Ancient\nVideo Games",
	"Diploma\nTime Travel Tourism",
	"Cert. Extreme\nPogo Stick Operation"
]

@export var affiliations = [
	"Sakura Rugby \nClub",
	"Escrime\nAcademy",
	"Harbour\nYacht Club",
	"Cricket\nAssociation",
	"Camel\nRacing Team",
	"Wushu\nInstitute",
	"Samba\nSchool",
	"Surf\nLifesaving Club",
	"Street\nFood Collective",
	"Futbol\nClub",
	"Ice Hockey\nFederation",
	"Marathon\nRunners",
	"Anti-Factoriohno\nLuddites",
	"Machine Killers\nAssoc.",
	"Anti-Capitalists\nMovement",
]


func _ready():
	education = educations.pick_random()
	affiliation = affiliations.pick_random()
	id = create_uid()
	sex = [ "male", "female","inter", "none"].pick_random()
	
func create_uid():
	var temp_id = ""
	var letters = "abcdefghijklmnopqrstuvwxyz"
	var numbers = "0123456789"
	for i in range(9):
		var list : String = [letters, numbers].pick_random()
		var characters = list.split() as Array
		temp_id += characters.pick_random()
	return temp_id
