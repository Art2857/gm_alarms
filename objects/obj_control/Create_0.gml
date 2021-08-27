
text = "box";

f = function(){show_message(text);}


alarm_loop_sync(100, function() {
	show_debug_message(__time);
});

activated = true;
obj = obj_test.id;
show_message_async(obj);
