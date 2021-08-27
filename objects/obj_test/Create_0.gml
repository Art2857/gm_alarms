
text = "Hello";

destroy = alarm_create({timeSet: 1, func: function(){ show_debug_message("alarm!"); }});

destroy.set_destroy_callback(function(){ show_debug_message("Destroy!"); });

/*alarm_loop_sync(10, function() {
	show_debug_message(__time);
}).set_destroy(true).set_destroy_callback(true);

alarm_loop_sync(25, function() {
	show_debug_message(__time);
});*/

limit = alarm_limit_sync(5, 50, function() {
	show_debug_message(__time);
});

limit.set(10000);
limit.data.alarm_loop.set(10);

