
text = "Hello";

destroy = alarm_create({func: function(){ show_message("destroy!"); }});

destroy.set_destroy_callback(true);

/*alarm_loop_sync(10, function() {
	show_debug_message(__time);
}).set_destroy(true).set_destroy_callback(true);

alarm_loop_sync(25, function() {
	show_debug_message(__time);
});*/

limit = alarm_limit_sync(5, 5000, function() {
	show_debug_message(__time);
});
show_message(limit.destroyed);

//limit.set_duration(1000);
limit.data.alarm_loop.set(10);

