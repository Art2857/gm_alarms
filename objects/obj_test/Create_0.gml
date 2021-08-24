
count=0;

alarm_limit_sync(1, 101, function() {
	
	alarm_limit_sync(1, 100, function() {
		count++;
	});
});

//	//alarm_sync(30, obj_control.f);

/*
alarm_loop_sync(0, function() {
	show_debug_message(__time);
});

alarm_sync(100, function() {
	//show_debug_message(__time);
});
