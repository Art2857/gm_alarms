
draw_set_color(make_color_rgb(192, 64, 128));

draw_text(20, 10, alarms_count());

draw_text(20, 60, alarms_count_sync());
draw_text(20, 90, alarms_count_async());

draw_text(20, 140, alarms_count_playing_sync());
draw_text(20, 170, alarms_count_playing_async());

draw_text(20, 200, current_time);
draw_text(20, 220, __async_time);

draw_text(20, 300, _alarm.time);
draw_text(20, 320, _alarm.timeSet);
