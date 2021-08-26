
count1=0;
count2=0;

text = "Hello";

alarm_sync(10, function() {
	
	//show_message(self);
	alarm_sync(1, obj_control.f);
});

/*
alarm_sync(1).set_destroy(false);
alarm_sync(2);
alarm_sync(3).set_destroy(false);
alarm_sync(4).set_destroy(false);
alarm_sync(5);


alarm_limit_sync(1, 100, function(data, this) {
	count1++;
	alarm_limit_sync(1, 100, function(data, this) {
		count2++;
		show_debug_message([count1, count2]);
		
		//show_message(object_get_name(id.object_index));
	});
});

/*alarm_loop_sync(1, function() {
	show_debug_message(count1++);
});*/

//	//alarm_sync(30, obj_control.f);

/*
alarm_loop_sync(0, function() {
	show_debug_message(__time);
});

alarm_sync(100, function() {
	//show_debug_message(__time);
});
