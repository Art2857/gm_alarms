//https://vk.com/clubgamemakerpro
//Обработка будильников
//_timeJump - скорость синхронных будильников, рекомендуемая скорость 1
function alarm_update(_timeJump=1) {
	//Обработка синхронных будильников
	if (__time >= __minSync) {
		while(ds_priority_size(__alarmsSync)){
			var _alarm = ds_priority_find_min(__alarmsSync);
			var _vtime = _alarm.time;
			 
			if (__time >= _vtime) {
				with (_alarm) {
					if (self.loop) {
						if(self.timeSet > 0){
							if (self.repeating) {
								var _rep = ceil((__time - self.time) / self.timeSet);
								repeat _rep {
									self.func(self.data, self);
								}
								self.time += _rep * self.timeSet;
							} else {
								self.func(self.data, self);
								self.time = __time + self.timeSet;
							}
							ds_priority_change_priority(__alarmsSync, self, self.time);
						}
					} else {
						self.func(self.data, self);
						if (self.destroyed)
							self.del();
						else
							self.stop();
					}
				}
			} else {
				__minSync = _vtime;
				break;
			}
		}
	}
	
	//Обработка асинхронных будильников
	if (current_time >= __minAsync) {
		while(ds_priority_size(__alarmsAsync)){//for(var i=0; i<ds_priority_size(__alarmsAsync); i++){//repeat ds_priority_size(__alarmsAsync) {
			var _alarm = ds_priority_find_min(__alarmsAsync);
			var _vtime = _alarm.time;
			
			if (current_time >= _vtime) {
				with (_alarm) {
					if (self.loop) {
						if(self.timeSet > 0){
							if (self.repeating) {
								var _rep = ceil((current_time - self.time) / self.timeSet);
								repeat _rep {
									self.func(self.data, self);
								}
								self.time += _rep * self.timeSet;
							} else {
								self.func(self.data, self);
								self.time = current_time + self.timeSet;
							}
							ds_priority_change_priority(__alarmsAsync, self, self.time);
						}
					} else {
						self.func(self.data, self);
						if (self.destroyed)
							self.del();
						else
							self.stop();
					}
				}
			} else {
				__minAsync = _vtime;
				break;
			}
		}
	}
	__time += _timeJump;
}
