
if(activated){
	instance_deactivate_all(true); //instance_deactivate_object(obj);
}else{
	instance_activate_all(); //instance_activate_object(obj);
}

activated = !activated;
