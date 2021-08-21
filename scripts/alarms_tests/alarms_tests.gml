
function test(_expr, _mess="") {
	if (!_expr) show_error(true, _mess);	
}

var _alarm = alarm_create();
test(alarm_exists(_alarm), "not exists");
test(alarm_find(_alarm) == _alarm, "not find");
test(alarm_get_data(_alarm) == undefined, "not correct data");
test(alarm_get_func(_alarm), "is done");
