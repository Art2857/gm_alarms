
text=123;

//alarm_limit_sync(0, 100, function() {
//	show_debug_message(__time);
//	//alarm_sync(30, obj_control.f);

//});

alarm_loop_sync(0, function() {
	show_debug_message(__time);
});

alarm_sync(100, function() {
	//show_debug_message(__time);
});
