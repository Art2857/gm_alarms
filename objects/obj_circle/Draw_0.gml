
draw_set_color(c_red);
draw_circle(x, y, 20, false);

draw_set_color(c_blue);
draw_text(x, y+32, alarm_get_lost(a));
