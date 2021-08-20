//https://vk.com/clubgamemakerpro
//Обработка будильников
//timeJump - скорость синхронных будильников, рекомендуемая скорость 1
function alarm_update(timeJump=1){
	//Обработка синхронных будильников
	if(__time>=__minSync){
		repeat ds_priority_size(__alarmsSync){
			var _alarm=ds_priority_find_min(__alarmsSync);
				var vtime=_alarm.time;
			 
				if(__time>=vtime){
					with(_alarm){
						if(loop){
							if(repeating && timeSet>0){
								var rep=ceil((__time-time)/timeSet);
								if(is_method(func)){
									repeat rep{
										if(is_struct(object) or instance_exists(object)){
											with object {other.func(other.data, other.this);}
										}else{
											func(data, this);
										}
									}
								}
								time+=rep*timeSet;
							}else{
								if(is_method(func)){
								if(is_struct(object) or instance_exists(object)){
										with object {other.func(other.data, other.this);}
									}else{
										func(data, this);
									}
								}
								time=__time+timeSet;
							}
							ds_priority_change_priority(__alarmsSync, this, time);
						}else{
							if(is_method(func)){
								if(is_struct(object) or instance_exists(object)){
									with object {other.func(other.data, other.this);}
								}else{
									func(data, this);
								}
							}
							if(destroyed){
								del();
							}else{
								stop();
							}
						}
					}
				}else{
					__minSync=vtime;
					break;
				}
			
		}
	}
	
	//Обработка асинхронных будильников
	if(current_time>=__minAsync){
		repeat ds_priority_size(__alarmsAsync){
			var _alarm=ds_priority_find_min(__alarmsAsync);
				var vtime=_alarm.time;
			
				if(current_time>vtime){
					with(_alarm){
						if(loop){
							if(repeating && timeSet>0){
								var rep=ceil((current_time-time)/timeSet);
								if(is_method(func)){
									repeat rep{
										if(is_struct(object) or instance_exists(object)){
											with object {other.func(other.data, other.this);}
										}else{
											func(data, this);
										}
									}
								}
								time+=rep*timeSet;
							}else{
								if(is_method(func)){
									if(is_struct(object) or instance_exists(object)){
										with object {other.func(other.data, other.this);}
									}else{
										func(data, this);
									}
								}
								time=current_time+timeSet;
							}
							ds_priority_change_priority(__alarmsAsync, this, time);
						}else{
							if(is_method(func)){
								if(is_struct(object) or instance_exists(object)){
									with object {other.func(other.data, other.this);}
								}else{
									func(data, this);
								}
							}
							if(destroyed){
								del();
							}else{
								stop();
							}
						}
					}
				}else{
					__minAsync=vtime;
					break;
				}
		}
	}
	__time+=timeJump;
}
