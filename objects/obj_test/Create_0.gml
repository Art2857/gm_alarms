
count1=0;
count2=0;

alarm_sync(50, function(){

	alarm_limit_sync(1, 5, function(data, this) {
		count1++;
		alarm_limit_sync(1, 5, function(data, this) {
			count2++;
			show_debug_message([count1, count2]);
		});
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
