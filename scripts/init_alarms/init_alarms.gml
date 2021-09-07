/// Синхронные и асинхронные будильники V3.3

// https://vk.com/clubgamemakerpro
// Асинхронные будильники отличаются от синхронных, тем что не зависят от fps
// Колбэк - это функция, которая произойдёт при активации будильника
// Синхронные будильники задаются в шагах игры, асинхронные в милисекундах (в секунде - 1000 милисекунд)

if (variable_global_exists("__alarms")) exit;

function alarm_default_func() {};

/*function instances_get(object__index){// Возвращает массив экземпляров объекта
	var array = [];
	with object__index{
		array_push(array, id);
	}
	return array;
}*/

globalvar _alarms_objects, _objects_deactive;

_alarms_objects = ds_map_create();// { object_or_struct: { alarm_name: alarm , ... } , ... }	// Будильники объекта
_objects_deactive = ds_map_create();// { object: { alarm_name: alarm , ... } , ... }			// Деактивированные будильники объекта



function alarms_object_deactivated_delete(){
	var object = ds_map_find_first(_objects_deactive);
	repeat ds_map_size(_objects_deactive){
		var _alarms = _objects_deactive[? object], _alarm_name, _alarm;
		if(_alarms != undefined){
			_alarm_name = ds_map_find_first(_alarms);
			repeat ds_map_size(_alarms){
				_alarm = _alarms[? _alarm_name];
			
				alarm_delete(_alarm);
				_alarm_name = ds_map_find_next(_alarms, _alarm_name);
			}
			ds_map_clear(_alarms);
		}
		
		object = ds_map_find_next(_objects_deactive, object);
	}
}

function alarms_room_end(_func){
	alarms_foreach(function(_alarm, _func){
			
		with _alarm{
			var _vfunc = self[$ _func];
			//if(_vfunc == undefined){if(!_alarm._persistent){alarm_delete(_alarm);}}else{
				with (self.link) _vfunc(other.data, other);
			//}
		}
		
	}, _func);
}

//room_goto(numb)
//room_next(numb)
//room_goto_next()
//room_goto_previous()
//room_restart()
//game_restart()

#macro room_goto replace_room_goto
#macro macro_room_goto room_goto
function replace_room_goto(numb){
	alarms_room_end("func_room_end");
	alarms_object_deactivated_delete();
	macro_room_goto(numb);
}

#macro room_next replace_room_next
#macro macro_room_next room_next
function replace_room_next(numb){
	alarms_room_end("func_room_end");
	alarms_object_deactivated_delete();
	macro_room_next(numb);
}

#macro room_goto_next replace_room_goto_next
#macro macro_room_goto_next room_goto_next
function replace_room_goto_next(){
	alarms_room_end("func_room_end");
	alarms_object_deactivated_delete();
	macro_room_goto_next();
}

#macro room_goto_previous replace_room_goto_previous
#macro macro_room_goto_previous room_goto_previous
function replace_room_goto_previous(){
	alarms_room_end("func_room_end");
	alarms_object_deactivated_delete();
	macro_room_goto_previous();
}

#macro room_restart replace_room_restart
#macro macro_room_restart room_restart
function replace_room_restart(){
	alarms_room_end("func_room_restart");
	alarms_object_deactivated_delete();
	macro_room_restart();
}

#macro game_restart replace_game_restart
#macro macro_game_restart game_restart
function replace_game_restart(){
	/*alarms_foreach(function(_alarm){
			
		with _alarm{
			var _vfunc = self[$ "func_game_restart"];
			//if(_vfunc == undefined){alarm_delete(_alarm);}else{
				with (self.link) _vfunc(other.data, other);
			//}
		}
		
	});*/
	alarms_room_end("func_game_restart");
	alarms_object_deactivated_delete();
	alarms_reset_time();
	macro_game_restart();
}

#macro instance_destroy replace_instance_destroy
#macro macro_instance_destroy instance_destroy
function replace_instance_destroy(object = self){// 
	var _alarm_deactive = _objects_deactive[? object];
	if(_alarm_deactive != undefined){	
		ds_map_destroy(_alarm_deactive);
	}
	ds_map_delete(_objects_deactive, object);

	with object{
		alarms_object_foreach(self, function(_alarm){
			if(_alarm.destroyed_instance){
				with _alarm{
					var _vfunc = self.deactivated;//Чё-то тут явно не так....................
					with (self.link) _vfunc(other.data, other);
				}
			
				_alarm.del();
			}
		});
	}

	macro_instance_destroy(object);
}

#macro instance_activate_all replace_instance_activate_all
#macro macro_instance_activate_all instance_activate_all
function replace_instance_activate_all(){// 
	macro_instance_activate_all();
	
	var object = ds_map_find_first(_objects_deactive);
	repeat ds_map_size(_objects_deactive){
		var _alarms = _objects_deactive[? object], _alarm_name, _alarm;
		if(_alarms != undefined){
			_alarm_name = ds_map_find_first(_alarms);
			repeat ds_map_size(_alarms){
				_alarm = _alarms[? _alarm_name];
				//if(_alarm.activated_resume) _alarm.resume();
			
				with _alarm{
					var _vfunc = self.activated;
					with (self.link) _vfunc(other.data, other);
				}
				//alarm_delete(_alarm);
				_alarm_name = ds_map_find_next(_alarms, _alarm_name);
			}
			ds_map_clear(_alarms);
		}
		
		/*for(var i = 0; i < array_length(_alarms); i++){
			_alarm = _alarms[i];
			_alarm.resume();
		}
		array_resize(_alarms, 0);
		*/
		/*with object {
			var _alarms = alarms_object_get_playing(self), _alarm;//alarms_object_resume(self);
			for(var i = 0; i < array_length(_alarms); i++){
				_alarm = _alarms[i];
				_alarm.resume();
			}
		}*/
		object = ds_map_find_next(_objects_deactive, object);
	}
	
	ds_map_clear(_objects_deactive);
}

#macro instance_activate_object replace_instance_activate_object
#macro macro_instance_activate_object instance_activate_object
function replace_instance_activate_object(obj){// 
	macro_instance_activate_object(obj);
	
	with obj{
		var _alarms_deactive = _objects_deactive[? self], _alarm_name, _alarm;
		if(_alarms_deactive != undefined){
			_alarm_name = ds_map_find_first(_alarms_deactive);
			repeat ds_map_size(_alarms_deactive){
				_alarm = _alarms_deactive[? _alarm_name];
				//if(_alarm.activated_resume) _alarm.resume();
			
				with _alarm{
					var _vfunc = self.activated;
					with (self.link) _vfunc(other.data, other);
				}
			
				_alarm_name = ds_map_find_next(_alarms_deactive, _alarm_name);
			}
			ds_map_destroy(_alarms_deactive);
		}
		
		ds_map_delete(_objects_deactive, self);
	}
}

#macro instance_activate_region replace_instance_activate_region
#macro macro_instance_activate_region instance_activate_region
function replace_instance_activate_region(left, top, width, height, inside){// 
	macro_instance_activate_region(left, top, width, height, inside);
}

#macro instance_deactivate_all replace_instance_deactivate_all
#macro macro_instance_deactivate_all instance_deactivate_all
function replace_instance_deactivate_all(notme){// 
	
	ds_map_clear(_objects_deactive);
	with all{
		if(!notme || (notme && self.id != other.id)){
			var _alarms_deactive;
			_alarms_deactive = _objects_deactive[? self];
			if(_alarms_deactive == undefined){
				var _alarms_deactive = ds_map_create();
			}
		
			alarms_object_foreach_playing(self, function(_alarm, _alarms_deactive){
			
				with _alarm{
					var _vfunc = self.deactivated;
					with (self.link) _vfunc(other.data, other);
				}
			
				if(_alarm.deactivated_stop){
					ds_map_add(_alarms_deactive, _alarm.name, _alarm);
					
					_alarm.stop();
				}
			}, _alarms_deactive);
		
			ds_map_add(_objects_deactive, self, _alarms_deactive);
			
			//ds_map_add(_objects_deactive, self, self);
			//alarms_object_stop_all(self);
		}
	}
	
	macro_instance_deactivate_all(notme);
}

#macro instance_deactivate_object replace_instance_deactivate_object
#macro macro_instance_deactivate_object instance_deactivate_object
function replace_instance_deactivate_object(obj){// 
	
	with obj{
		var _alarms_deactive;
		_alarms_deactive = _objects_deactive[? self];
		if(_alarms_deactive == undefined){
			var _alarms_deactive = ds_map_create();
		}
		
		alarms_object_foreach_playing(self, function(_alarm, _alarms_deactive){
			with _alarm{
				var _vfunc = self.deactivated;
				with (self.link) _vfunc(other.data, other);
			}
			
			if(_alarm.deactivated_stop){
				ds_map_add(_alarms_deactive, _alarm.name, _alarm);
			
				_alarm.stop();
			}
		}, _alarms_deactive);
		
		ds_map_add(_objects_deactive, self, _alarms_deactive);
	}
	
	macro_instance_deactivate_object(obj);
}

#macro instance_deactivate_region replace_instance_deactivate_region
#macro macro_instance_deactivate_region instance_deactivate_region
function replace_instance_deactivate_region(left, top, width, height, inside, notme){// 
	macro_instance_deactivate_region(left, top, width, height, inside, notme);
}

globalvar __alarms, __alarmsSync, __alarmsAsync, __minSync, __minAsync, __sync_time, __async_offset, __sync_speed, __async_speed, __async_time;
__alarms		= ds_map_create();			// Все будильники

__sync_time		= 0;						// Кол-во итераций alarm_update
__sync_speed	= 1;						// Скорость воспроизведения синхронных будильников
__alarmsSync	= ds_priority_create();		// Активные синхронные будильники
__minSync		= 0;						// Следующий синхронный будильник(Время)

__async_time	= current_time;				// Реальное время(Асинхронное время)
__async_speed	= 1;						// Скорость воспроизведения асинхронных будильников
__alarmsAsync	= ds_priority_create();		// Асинхронные синхронные будильники
__minAsync		= 0;						// Следующий асинхронный будильник(Время)
__async_offset	= current_time;				// Смещение времени асинхронных будильников

// Создаём "Класс" будильника:
function ClassAlarm() constructor { // Выступает одновременно в виде будильника и таймера
	
	self.status				= false;						// true - работает, false - остановлен
	self.time				= __sync_time;					// Время, когда сработает будильник
	self.timeSet			= 0;							// Через какое время будильник сработает(Каждые ...)
				         				                
	self.timePoint			= __sync_time;					// Время, когда будильник был остановлен или запущен
	self.timer				= 0;							// время таймера, до последнего запуска
										                
	self.destroyed			= false;						// Удалить после исполнения колбэка(true) или нет(false)
	self.destroyed_instance = false;						// Удалить будильник при удалении привязанного объекта
	self.destroyed_callback = false;						// Исполнить колбэк при удалении будильника
	
	self.deactivated_stop = true;							// Останавливать будильник при деактивации
	//self.activated_resume = true;							// Возобновлять будильник при активации объекта
	self.activated			= function(data, _alarm){return _alarm.resume();};// Исполнить колбэк при активации объекта
	self.deactivated		= alarm_default_func;			// Исполнить колбэк при деактивации объекта
	self.func_room_end			= /*undefined;*/function(_data, _alarm){if(!_alarm._persistent){alarm_delete(_alarm);}}// Исполняемая функция, которая сработает если перейти в другую комнату
	self.func_room_restart		= /*undefined;*/function(_data, _alarm){if(!_alarm._persistent){alarm_delete(_alarm);}}//
	self.func_game_restart		= /*undefined;*/function(_data, _alarm){alarm_delete(_alarm);}//
	
	self._persistent = false;
	
	self.func				= alarm_default_func;			// функция, которая сработает при истечении времени
	self.loop				= false;	                    // true - повторять, false - исполнить один раз
	self.sync				= true;							/* true - выполняется в шагах игры(время указывается в шагах), 
															** false - в реальном времени(время указывается в секундах)
					      									*/
										                
	self.repeating			= false;						/* Если за время между вызовами alarm_update, 
															** если будильник мог произойти n раз, тогда и функция будет исполнена n раз. 
															** Работает только с sync=false и loop=true.
															*/
	
	self.link				= self;
	
	static set_name				= function(_argName)           { return alarm_set_name(self, _argName);           } // Устанавливает название будильника
	static set_sync				= function(_argSync, _argTime) { return alarm_set_sync(self, _argSync, _argTime); } // Устанавливаем тип будильника и время
	
	static set					= function(_argTime)           { return alarm_set_duration(self, _argTime);       } // Устанавливаем время
	static get					= function()                   { return alarm_get_difference(self);               } // Сколько осталось времени до срабатывания будильника
	
	static set_destroy			= function(_destroyed)         { return alarm_set_destroy(self, _destroyed);      } //
	static set_destroy_callback = function(_destroyed){return alarm_set_destroy_callback(self, _destroyed);}
	static set_loop				= function(_loop)              { self.loop = _loop;                               } //
	
	static get_lost				= function()                   { return alarm_get_lost(self);                     } //
	static get_duration			= function()                   { return alarm_get_duration(self);                 } //
	static get_progress			= function()                   { return alarm_get_progress(self);                 } //
	static get_done_time		= function()                   { return alarm_get_done_time(self);                } //
	
	static set_data				= function(_data)              { return alarm_set_data(self, _data);              } //
	static get_data				= function()                   { return alarm_get_data();                         } //
	static set_func				= function(_callback)          { return alarm_set_func(self, _callback);          } // 
	static get_func				= function()                   { return alarm_get_func();                         } //
	
	static resume				= function()                   { return alarm_resume(self);                       } // Продолжить выполнение будильника
	static stop					= function()                   { return alarm_stop(self);                         } // Остановить будильник
	static replay				= function()                   { return alarm_replay(self);                       } // Перезапустить будильник
	
	static timer_get			= function()                   { return alarm_timer_get(self);                    } // Возвращает значение таймера
	static timer_clear			= function()                   { return alarm_timer_clear(self);                  } // Очистить таймер
	static timer_reset			= function(_argTime)           { return alarm_timer_reset(self, _argTime);        } // Очистить таймер и установить его значение
	
	static del					= function()                   { return alarm_delete(self);                       } // Удалить будильник
	
	static settings				= 
		function() { // гарантируем наличие глобальных переменных
			init_alarms();
			return method(
				undefined, function(_setting)					{ return alarm_settings(self, _setting);          } //
			);
		}();
}

function alarm_settings(_alarm, _settings) {
	var _keysUp = variable_struct_get_names(_settings);
	var _size   = array_length(_keysUp);
	
	var _key, _value;
	for (var i = 0; i < _size; ++i) {
		_key   = _keysUp[i];
		_value = variable_struct_get(_settings, _keysUp[i]);
		
		switch (_key) {
		
		case "status":
			(_value ? alarm_resume : alarm_stop)(_alarm);
			break;
		
		case "duration":
			alarm_set_duration(_alarm, _value);
			break;
		
		case "time":
			alarm_set_duration(_alarm, _value - __sync_time);
			break;
		
		case "timeSet":
			_alarm.timeSet = max(1, _value);
			break;

		case "sync":
			alarm_set_sync(_alarm, _value);
			break;
		
		case "name":
			alarm_set_name(_alarm, _value);
			break;
		
		case "func":
			alarm_set_func(_alarm, _value);
			break;
		
		default: variable_struct_set(_alarm, _key, _value);
		}
	}
	array_resize(_keysUp, 0);
	
	return _alarm;
}
