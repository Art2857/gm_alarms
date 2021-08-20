//https://vk.com/clubgamemakerpro
//Обработка будильников
//timeJump - скорость синхронных будильников, рекомендуемая скорость 1
function alarm_update(timeJump=1){
	//Обработка синхронных будильников
	if(_time>=_minSync){
		repeat ds_priority_size(_alarmsSync){
			var _alarm=ds_priority_find_min(_alarmsSync);
				var vtime=_alarm.time;
			 
				if(_time>=vtime){
					with(_alarm){
						if(loop){
							if(repeating && timeSet>0){
								var rep=ceil((_time-time)/timeSet);
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
								time=_time+timeSet;
							}
							ds_priority_change_priority(_alarmsSync, this, time);
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
					_minSync=vtime;
					break;
				}
			
		}
	}
	
	//Обработка асинхронных будильников
	if(current_time>=_minAsync){
		repeat ds_priority_size(_alarmsAsync){
			var _alarm=ds_priority_find_min(_alarmsAsync);
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
							ds_priority_change_priority(_alarmsAsync, this, time);
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
					_minAsync=vtime;
					break;
				}
		}
	}
	_time+=timeJump;
}
