
function alarm_default_func() {};

function struct_get_struct(_object) {
	switch (typeof(_object)) {
	case "struct":
		return _object;
		break;
	case "number":
	//case "int32":
	//case "int64":
		if (instance_exists(_object)) {
			
			with (_object) return self;
		}
		break;
	}
	return undefined;
}

//function is_function(_func) {
	
//	return (is_method(_func) or (is_numeric(_func) and script_exists(_func)));
//}
