
text = "Hello";


destroy = alarm_create({func: function(){ /*  */}});

destroy.set_destroy_callback(true);


alarm_sync(10, function() {
	show_debug_message(__time);
}).set_destroy(true).set_destroy_callback(true);


alarm_loop_sync(25, function() {
	show_debug_message(__time);
}).set_destroy(true);



limit = alarm_limit_sync(5, 5000, function() {
	show_debug_message(__time);
});

limit.set_duration(1000);
limit.alarm_loop.set_duration(100);


