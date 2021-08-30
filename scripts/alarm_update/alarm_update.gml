//https://vk.com/clubgamemakerpro
//Обработка будильников
function alarm_update() {
	//Обработка синхронных будильников
	if (__time >= __minSync) {
		while (ds_priority_size(__alarmsSync)) {
			var _alarm = ds_priority_find_min(__alarmsSync);
			var _vtime = _alarm.time;
			var _vfunc = _alarm.func;

			if (__time >= _vtime) {
				with (_alarm) {
					if (self.loop) {
						if (self.timeSet > 0) {
							if (self.repeating) {
								var _rep = ceil((__time - self.time) / self.timeSet);
								with (self.link) {
									repeat _rep {
										_vfunc(other.data, other);
									}
								}
								self.time += _rep * self.timeSet;
							} else {
								with (self.link) _vfunc(other.data, other);
								self.time = __time + self.timeSet;
							}
							ds_priority_change_priority(__alarmsSync, self, self.time);
						}
					} else {
						with (self.link) _vfunc(other.data, other);
						if (self.destroyed){
							self.del();
						}else{
							self.stop();
						}
					}
				}
			} else {
				__minSync = _vtime;
				break;
			}
		}
	}
	
	__current_time = (current_time - __async_offset ) * __async_speed;
	//Обработка асинхронных будильников
	if (__current_time >= __minAsync) {
		while (ds_priority_size(__alarmsAsync)) {
			var _alarm = ds_priority_find_min(__alarmsAsync);
			var _vtime = _alarm.time;
			var _vfunc = _alarm.func;
			
			if (__current_time >= _vtime) {
				with (_alarm) {
					if (self.loop) {
						if (self.timeSet > 0) {
							if (self.repeating) {
								var _rep = ceil((__current_time - self.time) / self.timeSet);
								with (self.link) {
									repeat _rep {
										_vfunc(other.data, other);
									}
								}
								self.time += _rep * self.timeSet;
							} else {
								with (self.link) _vfunc(other.data, other);
								self.time = __current_time + self.timeSet;
							}
							ds_priority_change_priority(__alarmsAsync, self, self.time);
						}
					} else {
						with (self.link) _vfunc(other.data, other);
						if (self.destroyed){
							self.del();
						}else{
							self.stop();
						}
					}
				}
			} else {
				__minAsync = _vtime;
				break;
			}
		}
	}
	
	__time += __sync_speed;
}
