
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

function method_bind(_func, _object = self){
	if(is_method(_func)){
		_func = method(_object, method_get_index(_func));
	}else{
		if(is_numeric(_func) && script_exists(_func)){
			_func = method(_object, _func);
		}
	}
	return _func;
}

//function is_function(_func) {
	
//	return (is_method(_func) or (is_numeric(_func) and script_exists(_func)));
//}
