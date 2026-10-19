extends Resource
class_name OperationalSysytem


@export var env: Dictionary[String, Variant]
@export_multiline("Put code here")
var entred_code: String

@export var signals: Dictionary[String, String] = {
	"open": "Opens the object with a specific id"
}
