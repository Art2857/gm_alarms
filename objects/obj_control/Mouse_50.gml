
if(!alarm_exists("alarm")){
	instance_create_depth(mouse_x, mouse_y, 0, obj_circle);
	
	alarm_sync(4).set_name("alarm");
}
