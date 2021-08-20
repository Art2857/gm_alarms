//https://vk.com/clubgamemakerpro
/*
Параметры(Только для чтения):
	this - Возвратный идентификатор будильника
	name - имя будильника
	status - статус будильник, запущен(true) или остановлен(false*)
	time -Время, когда сработает будильник
	timeSet - промежуток, через который срабатывает будильник
	timePoint - время последнего изменения состояния будильника
	timer - время таймера, до последнего запуска
	sync - будильник делает отчёт в шагах игры(true*) или в реальном времени(false)
	
Параметры(Для чтения и установки):
	func - функция активации будильника function(){}*
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

function alarm_create(/*{setting}*/){

	_alarm=new classAlarm();//Создаём будильник
	
	_alarm.this = _alarm;//Устанавливаем 
	_alarm.name = _alarm;//Устанавливаем имя как идентификатор самого себя
	_alarm.object = self;
	_alarm.data = undefined;
	
	ds_map_add(_alarms, _alarm.name, _alarm);
	
	if(argument_count>0){//Если при создании были указны настройки в структуре
		_alarm.settings(argument[0]);//то применяем их к ново-созданному будильнику
	}
	
	return _alarm;//Возвращаем ново-созданный будильник
}
//https://vk.com/clubgamemakerpro

//Удаляет будильник
function alarm_delete(thisAlarm){
	if(is_string(thisAlarm)){thisAlarm=alarm_find(thisAlarm); if is_undefined(thisAlarm) return undefined;}
	ds_priority_delete_value(_alarmsSync, thisAlarm);
	ds_priority_delete_value(_alarmsAsync, thisAlarm);
	ds_map_delete(_alarms, thisAlarm.name);
	delete thisAlarm;
}
//https://vk.com/clubgamemakerpro

//Проверяем на существование будильник по его имени
function alarm_exists(thisAlarm){
	if(is_string(thisAlarm)){thisAlarm=alarm_find(thisAlarm); if is_undefined(thisAlarm) return undefined;}
	return !is_undefined(_alarms[?thisAlarm]);
}
//https://vk.com/clubgamemakerpro

//Возвращает структуру будильника по его установленному имени
function alarm_find(name){
	return _alarms[?name];
}
//https://vk.com/clubgamemakerpro

//Возвращает разницу от текущего времени до срабатывания будильника
function alarm_get_difference(thisAlarm){
	if(is_string(thisAlarm)){thisAlarm=alarm_find(thisAlarm); if is_undefined(thisAlarm) return undefined;}
	with(thisAlarm){
		if(status){
			if(sync){
				return time-_time;
			}else{
				return time-current_time;
			}
		}else{
			return time-timePoint;
		}
	}
}
//https://vk.com/clubgamemakerpro

//Возвращает время до срабатывания будильника
function alarm_get_done_time(thisAlarm){
	if(is_string(thisAlarm)){thisAlarm=alarm_find(thisAlarm); if is_undefined(thisAlarm) return undefined;}
	with(thisAlarm){
		return get_lost()==0;
	}
}
//https://vk.com/clubgamemakerpro

function alarm_get_duration(thisAlarm){
	if(is_string(thisAlarm)){thisAlarm=alarm_find(thisAlarm); if is_undefined(thisAlarm) return undefined;}
	with(thisAlarm){
		return timeSet;
	}
}

//Возвращает время до срабатывания будильника
function alarm_get_lost(thisAlarm){
	if(is_string(thisAlarm)){thisAlarm=alarm_find(thisAlarm); if is_undefined(thisAlarm) return undefined;}
	with(thisAlarm){
		if(status){
			if(sync){
				return max(0, time-_time);
			}else{
				return max(0, time-current_time);
			}
		}else{
			return max(0, time-timePoint);
		}
	}
}
//https://vk.com/clubgamemakerpro

function alarm_get_progress(thisAlarm){
	if(is_string(thisAlarm)){thisAlarm=alarm_find(thisAlarm); if is_undefined(thisAlarm) return undefined;}
	with(thisAlarm){
		return (timeSet-get_lost())/timeSet;
	}
}

//Перезапускает будильник
function alarm_replay(thisAlarm){
	if(is_string(thisAlarm)){thisAlarm=alarm_find(thisAlarm); if is_undefined(thisAlarm) return undefined;}
	return thisAlarm.resume().set(thisAlarm.timeSet);
}
//https://vk.com/clubgamemakerpro

//Запускает будильник
function alarm_resume(thisAlarm){
	if(is_string(thisAlarm)){thisAlarm=alarm_find(thisAlarm); if is_undefined(thisAlarm) return undefined;}
	with(thisAlarm){
		if (!status){
			status=true; 
			if(sync){
				time+=_time-timePoint;
				timePoint=_time;
				if(time<_minSync){_minSync=time;}
				if(is_undefined(ds_priority_find_priority(_alarmsSync, thisAlarm))){
					ds_priority_add(_alarmsSync, thisAlarm, time);
				}else{
					ds_priority_change_priority(_alarmsSync, thisAlarm, time);
				}
			}else{
				time+=current_time-timePoint;
				timePoint=current_time;
				if(time<_minAsync){_minAsync=time;}
				if(is_undefined(ds_priority_find_priority(_alarmsAsync, thisAlarm))){
					ds_priority_add(_alarmsAsync, thisAlarm, time);
				}else{
					ds_priority_change_priority(_alarmsAsync, thisAlarm, time);
				}
			}
		}
	}
	return thisAlarm;
}
//https://vk.com/clubgamemakerpro

//Устанавливаем время, через которое сработает будильник
function alarm_set_duration(thisAlarm, argTime){
	if(is_string(thisAlarm)){thisAlarm=alarm_find(thisAlarm); if is_undefined(thisAlarm) return undefined;}
	with(thisAlarm){
		if(sync){
			time=_time+argTime;
			if(time<_minSync){_minSync=time;}
			if(!is_undefined(ds_priority_find_priority(_alarmsSync, thisAlarm))){
				ds_priority_change_priority(_alarmsSync, thisAlarm, time);
			}
		}else{
			time=current_time+argTime;
			if(time<_minAsync){_minAsync=time;}
			if(!is_undefined(ds_priority_find_priority(_alarmsAsync, thisAlarm))){
				ds_priority_change_priority(_alarmsAsync, thisAlarm, time);
			}
		}
		timeSet=argTime; 
	}
	return thisAlarm;
}
//https://vk.com/clubgamemakerpro

function alarm_set_data(thisAlarm, data){
	if(is_string(thisAlarm)){thisAlarm=alarm_find(thisAlarm); if is_undefined(thisAlarm) return undefined;}
	thisAlarm.data=data;
	return thisAlarm;
}

function alarm_get_data(thisAlarm){
	if(is_string(thisAlarm)){thisAlarm=alarm_find(thisAlarm); if is_undefined(thisAlarm) return undefined;}
	return thisAlarm.data;
}

function alarm_set_done(thisAlarm, callback){
	if(is_string(thisAlarm)){thisAlarm=alarm_find(thisAlarm); if is_undefined(thisAlarm) return undefined;}
	thisAlarm.func=callback;
	return thisAlarm;
}

function alarm_get_done(thisAlarm){
	if(is_string(thisAlarm)){thisAlarm=alarm_find(thisAlarm); if is_undefined(thisAlarm) return undefined;}
	return thisAlarm.func;
}

//Устанавливаем название будильника. Поиск будьника через alarm_find(name)
function alarm_set_name(thisAlarm, argName){
	if(is_string(thisAlarm)){thisAlarm=alarm_find(thisAlarm); if is_undefined(thisAlarm) return undefined;}
	with(thisAlarm){
		ds_map_delete(_alarms, name);
		ds_map_add(_alarms, argName, thisAlarm);
		
		if(status){
			if(sync){
				ds_priority_delete_value(_alarmsSync, thisAlarm);
				ds_priority_add(_alarmsSync, thisAlarm, time);
			}else{
				ds_priority_delete_value(_alarmsAsync, thisAlarm);
				ds_priority_add(_alarmsAsync, thisAlarm, time);
			}
		}
		name=argName;
	}
	return thisAlarm;
}
//https://vk.com/clubgamemakerpro

//Смена режим будильника и время срабатывания будильника
function alarm_set_sync(thisAlarm, argSync, argTime){
	if(is_string(thisAlarm)){thisAlarm=alarm_find(thisAlarm); if is_undefined(thisAlarm) return undefined;}
	with(thisAlarm){
		if(argTime!=undefined){
			if(argSync){
				time=_time+argTime;
				if(time<_minSync){_minSync=time;}
			}else{
				time=current_time+argTime;
				if(time<_minAsync){_minAsync=time;}
			}
			timeSet=argTime;
		}
		sync=argSync;
		
		if(status){
			if(argSync){
				ds_priority_delete_value(_alarmsAsync, thisAlarm);
			}else{
				ds_priority_delete_value(_alarmsSync, thisAlarm);
			}
		}
	}
	return thisAlarm;
}
//https://vk.com/clubgamemakerpro

//Останавливает будильник
function alarm_stop(thisAlarm){
	if(is_string(thisAlarm)){thisAlarm=alarm_find(thisAlarm); if is_undefined(thisAlarm) return undefined;}
	with(thisAlarm){
		if (status){
			status=false;
			if(sync){
				timer+=_time-timePoint;
				timePoint=_time;
				ds_priority_delete_value(_alarmsSync, thisAlarm);
			}else{
				timer+=current_time-timePoint;
				timePoint=current_time;
				ds_priority_delete_value(_alarmsAsync, thisAlarm);
			}
		}
	}
	return thisAlarm;
}
//https://vk.com/clubgamemakerpro

function alarm_set_destroy(thisAlarm, destroyed){
	if(is_string(thisAlarm)){thisAlarm=alarm_find(thisAlarm); if is_undefined(thisAlarm) return undefined;}
	thisAlarm.destroyed=destroyed;
}

//Обнуляем таймер будильника
function alarm_timer_clear(thisAlarm){
	if(is_string(thisAlarm)){thisAlarm=alarm_find(thisAlarm); if is_undefined(thisAlarm) return undefined;}
	with(thisAlarm){
		timer=0;
		if(sync){
			timePoint=_time;
		}else{
			timePoint=current_time;
		}
	}
	return thisAlarm;
}
//https://vk.com/clubgamemakerpro

//Возвращает время таймера
function alarm_timer_get(thisAlarm){
	if(is_string(thisAlarm)){thisAlarm=alarm_find(thisAlarm); if is_undefined(thisAlarm) return undefined;}
	with(thisAlarm){
		if(status){
			if(sync){
				return timer+(_time-timePoint);
			}else{
				return timer+(current_time-timePoint);
			}
		}else{
			return timer;
		}
	}
}
//https://vk.com/clubgamemakerpro

// Обнуляем таймер(В случае второго аргумента - устанавливаем значение)
function alarm_timer_reset(thisAlarm){
	if(is_string(thisAlarm)){thisAlarm=alarm_find(thisAlarm); if is_undefined(thisAlarm) return undefined;}
	with(thisAlarm){
		var prestatus=status;
		stop();
		if(argument_count>1){timer=argument[1];}else{timer=0;}
		if(prestatus){resume();}
	}
	return thisAlarm;
}
//https://vk.com/clubgamemakerpro

//Остановить все будильники
function alarms_all_stop(){
	var key=ds_map_find_first(_alarms);
	repeat ds_map_size(_alarms){
		if(alarm_exists(_alarms[?key])){_alarms[?key].stop();}
		key=ds_map_find_next(_alarms, key);
	}
}
//https://vk.com/clubgamemakerpro

//Возобновляем все будильники
function alarms_all_resume(){
	var key=ds_map_find_first(_alarms);
	repeat ds_map_size(_alarms){
		if(alarm_exists(_alarms[?key])){_alarms[?key].resume();}
		key=ds_map_find_next(_alarms, key);
	}
}
//https://vk.com/clubgamemakerpro

//Удаляем все будильники
function alarms_all_delete(){
	var key=ds_map_find_first(_alarms);
	repeat ds_map_size(_alarms){
		if(alarm_exists(_alarms[?key])){_alarms[?key].del();}
		key=ds_map_find_next(_alarms, key);
	}
	ds_priority_clear(_alarmsSync);
	ds_priority_clear(_alarmsAsync);
	ds_map_clear(_alarms);
}
//https://vk.com/clubgamemakerpro