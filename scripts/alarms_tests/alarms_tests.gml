
function test(_expr, _mess="") {
	if (!_expr) show_error(true, _mess);	
}
/*
var _alarm = alarm_create();
test(alarm_exists(_alarm), "not exists");
test(alarm_find(_alarm) == _alarm, "not find");
test(alarm_get_data(_alarm) == undefined, "not correct data");
test(alarm_get_func(_alarm), "is done");

var _ar_size = 100;
var _ar_almr = array_create(_ar_size);
for (var i = 0; i < _ar_size; ++i) {
	_ar_almr[i] = alarm_create();	
}
alarms_all_delete();
for (var i = 0; i < _ar_size; ++i) {
	if (alarm_exists(_ar_almr[i])) test(true, "error alarms_all_delete");
}

