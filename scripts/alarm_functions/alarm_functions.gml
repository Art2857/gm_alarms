
//https://vk.com/clubgamemakerpro
/*
Параметры(Только для чтения):
	self - Возвратный идентификатор будильника
	name - имя будильника
	status - статус будильник, запущен(true) или остановлен(false*)
	time -Время, когда сработает будильник
	timeSet - промежуток, через который срабатывает будильник
	timePoint - время последнего изменения состояния будильника
	timer - время таймера, до последнего запуска
	sync - будильник делает отчёт в шагах игры(true*) или в реальном времени(false)
	
Параметры(Для чтения и установки):
	func - функция активации будильника function(){}* (функции вызываются в пространстве будильника)
	destroyed - при активации будильника, будильник будет удалён(true) или останется (false*)
	loop - зацикливание будильника (true/false*)
	repeating - Если за время между вызовами alarm_update, 
					будильник мог произойти n раз, тогда и функция будет инициализирована n раз. 
					Работает только с sync=false и loop=true.

Методы(Для чтения или установки параметров. Описание читать внутри функций):
	set_name - идентично alarm_set_name
	set_sync - идентично alarm_sync
	set - идентично alarm_set_duration
	get - идентично alarm_get
	resume - идентично alarm_resume
	stop - идентично alarm_stop
	replay - идентично alarm_replay
	timer_get - идентично alarm_timer_get
	timer_clear - идентично alarm_timer_clear
	timer_reset - идентично alarmTimer
	del - идентично alarm_delete
	settings - идентично unite
	
Примеры:
	alarm_create().метод1().метод2();
	alarm_create().set(200);
	alarm_create({loop: true, func: function(){show_message("Будильник сработал!");} }).resume().setSync(false, 5000);
*/

/// @param [setting]
function alarm_create(/*{setting}*/) {
	
	var _thisAlarm = new ClassAlarm(); // Создаём будильник
	
	_thisAlarm.name = _thisAlarm; // Устанавливаем имя как идентификатор самого себя
	_thisAlarm.data = undefined;
	_thisAlarm.link = self;
	
	ds_map_add(__alarms, _thisAlarm.name, _thisAlarm);
	
	if (argument_count > 0) {             // Если при создании были указны настройки в структуре
		_thisAlarm.settings(argument[0]); // то применяем их к ново-созданному будильнику
	}
	
	return _thisAlarm; // Возвращаем ново-созданный будильник
}
// https://vk.com / clubgamemakerpro

// Удаляет будильник
function alarm_delete(_thisAlarm) {
	if (is_string(_thisAlarm)) { _thisAlarm = alarm_find(_thisAlarm); if (is_undefined(_thisAlarm)) return undefined; };
	ds_priority_delete_value(__alarmsSync, _thisAlarm);
	ds_priority_delete_value(__alarmsAsync, _thisAlarm);
	ds_map_delete(__alarms, _thisAlarm.name);
	delete _thisAlarm;
}
// https://vk.com/clubgamemakerpro

// Проверяем на существование будильник по его имени
function alarm_exists(_thisAlarm) {
	if (is_string(_thisAlarm)) { _thisAlarm = alarm_find(_thisAlarm); if (is_undefined(_thisAlarm)) return undefined; };
	return !is_undefined(__alarms[? _thisAlarm]);
}
// https: // vk.com/clubgamemakerpro

// Возвращает структуру будильника по его установленному имени
function alarm_find(name) {
	return __alarms[? name];
}
// https://vk.com/clubgamemakerpro

// Возвращает разницу от текущего времени до срабатывания будильника
function alarm_get_difference(_thisAlarm) {
	if (is_string(_thisAlarm)) { _thisAlarm = alarm_find(_thisAlarm); if (is_undefined(_thisAlarm)) return undefined; };
	with (_thisAlarm) {
		if (self.status) {
			if (self.sync)
				return (self.time - __time);
			else
				return (self.time - current_time);
		}
		return (self.time - self.timePoint);
	}
}
// https://vk.com/clubgamemakerpro

// Возвращает время до срабатывания будильника
function alarm_get_done_time(_thisAlarm) {
	if (is_string(_thisAlarm)) { _thisAlarm = alarm_find(_thisAlarm); if (is_undefined(_thisAlarm)) return undefined; };
	return (_thisAlarm.get_lost() == 0);
}
// https://vk.com/clubgamemakerpro

function alarm_get_duration(_thisAlarm) {
	if (is_string(_thisAlarm)) { _thisAlarm = alarm_find(_thisAlarm); if (is_undefined(_thisAlarm)) return undefined; };
	return _thisAlarm.timeSet;
}

// Возвращает время до срабатывания будильника
function alarm_get_lost(_thisAlarm) {
	if (is_string(_thisAlarm)) { _thisAlarm = alarm_find(_thisAlarm); if (is_undefined(_thisAlarm)) return undefined; };
	with (_thisAlarm) {
		if (self.status) {
			if (self.sync)
				return max(0, self.time - __time);
			else
				return max(0, self.time - current_time);
		}
		return max(0, self.time- self.timePoint);
	}
}
// https://vk.com/clubgamemakerpro

function alarm_get_progress(_thisAlarm) {
	if (is_string(_thisAlarm)) { _thisAlarm = alarm_find(_thisAlarm); if (is_undefined(_thisAlarm)) return undefined; };
	with (_thisAlarm) {
		return ((self.timeSet - self.get_lost()) / self.timeSet);
	}
}

// Перезапускает будильник
function alarm_replay(_thisAlarm) {
	if (is_string(_thisAlarm)) { _thisAlarm = alarm_find(_thisAlarm); if (is_undefined(_thisAlarm)) return undefined; };
	return _thisAlarm.resume().set(_thisAlarm.timeSet);
}
// https: // vk.com/clubgamemakerpro

// Запускает будильник
function alarm_resume(_thisAlarm) {
	if (is_string(_thisAlarm)) { _thisAlarm = alarm_find(_thisAlarm); if (is_undefined(_thisAlarm)) return undefined; };
	with (_thisAlarm) {
		if (!self.status) {
			self.status = true; 
			if (self.sync) {
				self.time     += __time - self.timePoint;
				self.timePoint = __time;
				if (self.time < __minSync) __minSync = self.time;
				if (is_undefined(ds_priority_find_priority(__alarmsSync, self)))
					ds_priority_add(__alarmsSync, self, self.time);
				else
					ds_priority_change_priority(__alarmsSync, self, self.time);
			} else {
				self.time     += current_time - self.timePoint;
				self.timePoint = current_time;
				if (self.time < __minAsync) __minAsync = self.time;
				if (is_undefined(ds_priority_find_priority(__alarmsAsync, self)))
					ds_priority_add(__alarmsAsync, self, time);
				else
					ds_priority_change_priority(__alarmsAsync, self, self.time);
			}
		}
	}
	return _thisAlarm;
}
// https:/ /vk.com/clubgamemakerpro

// Устанавливаем время, через которое сработает будильник
function alarm_set_duration(_thisAlarm, _argTime=1) {
	if (is_string(_thisAlarm)) { _thisAlarm = alarm_find(_thisAlarm); if (is_undefined(_thisAlarm)) return undefined; };
	_argTime = max(_argTime, 1);
	with (_thisAlarm) {
		if (self.sync) {
			self.time = __time + _argTime;
			if (self.time < __minSync) __minSync = self.time;
			if (!is_undefined(ds_priority_find_priority(__alarmsSync, self)))
				ds_priority_change_priority(__alarmsSync, self, self.time);
		} else {
			self.time = current_time + _argTime;
			if (self.time < __minAsync) __minAsync = self.time;
			if (!is_undefined(ds_priority_find_priority(__alarmsAsync, self)))
				ds_priority_change_priority(__alarmsAsync, self, self.time);
		}
		self.timeSet = _argTime;
	}
	return _thisAlarm;
}
// https://vk.com/clubgamemakerpro

function alarm_set_data(_thisAlarm, _data) {
	if (is_string(_thisAlarm)) { _thisAlarm = alarm_find(_thisAlarm); if (is_undefined(_thisAlarm)) return undefined; };
	_thisAlarm.data = _data;
	return _thisAlarm;
}

function alarm_get_data(_thisAlarm) {
	if (is_string(_thisAlarm)) { _thisAlarm = alarm_find(_thisAlarm); if (is_undefined(_thisAlarm)) return undefined; };
	return _thisAlarm.data;
}

function alarm_set_func(_thisAlarm, _callback) {
	if (is_string(_thisAlarm)) { _thisAlarm = alarm_find(_thisAlarm); if (is_undefined(_thisAlarm)) return undefined; };
	if (is_method(_callback))     _callback = method_get_index(_callback);
	//if ((is_numeric(_callback) && !script_exists(_callback)) || !_callback)
	if (!is_numeric(_callback) && !script_exists(_callback))
								  _callback = alarm_default_func;
	_thisAlarm.func = _callback;
	return _thisAlarm;
}

function alarm_get_func(_thisAlarm) {
	if (is_string(_thisAlarm)) { _thisAlarm = alarm_find(_thisAlarm); if (is_undefined(_thisAlarm)) return undefined; };
	return _thisAlarm.func;
}

// Устанавливаем название будильника. Поиск будьника через alarm_find(name)
function alarm_set_name(_thisAlarm, _argName) {
	if (is_string(_thisAlarm)) { _thisAlarm = alarm_find(_thisAlarm); if (is_undefined(_thisAlarm)) return undefined; };
	with (_thisAlarm) {
		ds_map_delete(__alarms, self.name);
		ds_map_add(__alarms, _argName, self);

		if (self.status) {
			if (self.sync) {
				ds_priority_delete_value(__alarmsSync, self);
				ds_priority_add(__alarmsSync, self, self.time);
			} else {
				ds_priority_delete_value(__alarmsAsync, self);
				ds_priority_add(__alarmsAsync, self, self.time);
			}
		}
		self.name = _argName;
	}
	return _thisAlarm;
}
// https://vk.com/ clubgamemakerpro

// Смена режим будильника и время срабатывания будильника
function alarm_set_sync(_thisAlarm, _argSync, _argTime=1) {
	if (is_string(_thisAlarm)) { _thisAlarm = alarm_find(_thisAlarm); if (is_undefined(_thisAlarm)) return undefined; };
	_argTime = max(_argTime, 1);
	with (_thisAlarm) {
		if (_argTime != undefined) {
			if (_argSync) {
				self.time = __time + _argTime;
				if (self.time < __minSync) __minSync = self.time;
			} else {
				self.time = current_time + _argTime;
				if (self.time < __minAsync) __minAsync = self.time;
			}
			self.timeSet = _argTime;
		}
		self.sync = _argSync;
		
		if (self.status) {
			if (_argSync)
				ds_priority_delete_value(__alarmsAsync, self);
			else
				ds_priority_delete_value(__alarmsSync, self);
		}
	}
	return _thisAlarm;
}
// https://vk.com/clubgamemakerpro

// Останавливает будильник
function alarm_stop(_thisAlarm) {
	if (is_string(_thisAlarm)) { _thisAlarm = alarm_find(_thisAlarm); if (is_undefined(_thisAlarm)) return undefined; };
	with (_thisAlarm) {
		if (self.status) {
			self.status = false;
			if (self.sync) {
				self.timer    += __time - self.timePoint;
				self.timePoint = __time;
				ds_priority_delete_value(__alarmsSync, self);
			} else {
				self.timer    += current_time - self.timePoint;
				self.timePoint = current_time;
				ds_priority_delete_value(__alarmsAsync, self);
			}
		}
	}
	return _thisAlarm;
}
// https://vk.com/clubgamemakerpro

function alarm_set_destroy(_thisAlarm, _destroyed) {
	if (is_string(_thisAlarm)) { _thisAlarm = alarm_find(_thisAlarm); if (is_undefined(_thisAlarm)) return undefined; };
	_thisAlarm.destroyed = _destroyed;
}

// Обнуляем таймер будильника
function alarm_timer_clear(_thisAlarm) {
	if (is_string(_thisAlarm)) { _thisAlarm = alarm_find(_thisAlarm); if (is_undefined(_thisAlarm)) return undefined; };
	with (_thisAlarm) {
		self.timer = 0;
		if (self.sync)
			self.timePoint = __time;
		else
			self.timePoint = current_time;
	}
	return _thisAlarm;
}
// https://vk. com/clubgamemakerpro

// Возвращает время таймера
function alarm_timer_get(_thisAlarm) {
	if (is_string(_thisAlarm)) { _thisAlarm = alarm_find(_thisAlarm); if (is_undefined(_thisAlarm)) return undefined; };
	with (_thisAlarm) {
		if (self.status) {
			if (self.sync)
				return (self.timer + (__time - self.timePoint));
			else
				return (self.timer + (current_time - self.timePoint));
		}
		return self.timer;
	}
}
// https://vk.com/ clubgamemakerpro

// Обнуляем таймер(В случае второго аргумента - устанавливаем значение)
function alarm_timer_reset(_thisAlarm, _time=0) {
	if (is_string(_thisAlarm)) { _thisAlarm = alarm_find(_thisAlarm); if (is_undefined(_thisAlarm)) return undefined; };
	with (_thisAlarm) {
		var _prestatus = self.status;
		self.stop();
		self.timer = _time;
		if (_prestatus) self.resume();
	}
	return _thisAlarm;
}
// https ://vk.com/clubgamemakerpro

// Остановить все будильники
function alarms_all_stop() {
	var _key = ds_map_find_first(__alarms);
	repeat ds_map_size(__alarms) {
		__alarms[? _key].stop();
		_key = ds_map_find_next(__alarms, _key);
	}
}
// https: //vk.com/clubgamemakerpro

// Возобновляем все будильники
function alarms_all_resume() {
	var _key = ds_map_find_first(__alarms);
	repeat ds_map_size(__alarms) {
		__alarms[? _key].resume();
		_key = ds_map_find_next(__alarms, _key);
	}
}
// https:// vk.com/clubgamemakerpro

// Удаляем все будильники
function alarms_all_delete() {
	var _key = ds_map_find_first(__alarms);
	var _alarm;
	repeat ds_map_size(__alarms) {
		_alarm = __alarms[? _key];
		_key = ds_map_find_next(__alarms, _key);
		_alarm.del();
	}
}
// https://vk.com/clubgam emakerpro

//Для работы со всеми будильниками
function alarms_count(){
	return ds_map_size(__alarms);
}

function alarms_count_active(){

}

function alarms_count_deactive(){

}

function alarms_foreach(){}
function alarms_foreach_active(){}
function alarms_foreach_deactive(){}


function alarms_get(){}
function alarms_get_active(){}
function alarms_get_deactive(){}

//Для работы с будильниками в пределах объекта
function alarms_clear(object = self) {
	
}

function alarms_count_object(object = self) {

}

function alarms_count_object_active(object = self) {

}

function alarms_count_object_deactive(object = self) {

}

function alarms_object_foreach(object = self) {}
function alarms_object_foreach_active(object = self) {}
function alarms_object_foreach_deactive(object = self) {}


function alarms_object_get(object = self) {}
function alarms_object_get_active(object = self) {}
function alarms_object_get_deactive(object = self) {}
