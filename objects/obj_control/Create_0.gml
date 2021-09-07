
text = "box";

f = function(){show_message(text);}

time = 60

_alarm = alarm_loop_sync(time, function() {
	show_debug_message(__sync_time);
	alarm_set_duration(_alarm, ++time);
});
alarm_set_persistent(_alarm);



obj = obj_test;//.id;
