
text = "box";

f = function(){show_message(text);}



_alarm = alarm_loop_sync(60, function() {
	show_debug_message(__async_time);
});
alarm_set_persistent(_alarm);



obj = obj_test;//.id;
