
text = "Hello";

//destroy = alarm_create({timeSet: 1, func: function(){ show_debug_message("alarm!"); }});
//destroy.set_destroy(true).set_destroy_callback(function(){ show_debug_message("Destroy!"); });


alarm_loop_async(100, function() {
	show_debug_message(__async_time);
}).set_destroy(true).set_destroy_callback(true);

alarm_loop_async(250, function() {
	show_debug_message(__async_time);
});

limit = alarm_limit_async(50, 500, function() {
	show_debug_message(__async_time);
});

limit.set(100000);
limit.data.alarm_loop.set(10);

