/// Синхронные и асинхронные будильники V3.3

// https://vk.com/clubgamemakerpro
// Асинхронные будильники отличаются от синхронных, тем что не зависят от fps
// Колбэк - это функция, которая произойдёт при активации будильника
// Синхронные будильники задаются в шагах игры, асинхронные в милисекундах (в секунде - 1000 милисекунд)

if (variable_global_exists("__alarms")) exit;

globalvar _alarms_objects;

_alarms_objects=ds_map_create();// { object_or_struct: { alarm_name: alarm , ... } , ... }

#macro instance_destroy replace_instance_destroy
#macro macro_instance_destroy instance_destroy


function replace_instance_destroy(object = self){
	alarms_clear(object);

	macro_instance_destroy(object);
}

function macro_instance_activate_all(){
	//instance_activate_all()
}

function macro_instance_activate_object(){
	//instance_activate_object()
}

function macro_instance_activate_region(){
	//instance_activate_region()
}

function macro_instance_deactivate_all(){
	//instance_deactivate_all()
}

function macro_instance_deactivate_object(){
	//instance_deactivate_object()
}

function macro_instance_deactivate_region(){
	//instance_deactivate_region()
}

globalvar __alarms, __alarmsSync, __alarmsAsync, __minSync, __minAsync, __time;
__alarms      = ds_map_create();      // Все будильники
__alarmsSync  = ds_priority_create(); // Активные синхронные будильники
__minSync     = 0;                    // Следующий синхронный будильник(Время)
__alarmsAsync = ds_priority_create(); // Асинхронные синхронные будильники
__minAsync    = 0;                    // Следующий асинхронный будильник(Время)
__time        = 0;                    // Кол-во итераций alarm_update

// Создаём "Класс" будильника:
function ClassAlarm() constructor { // Выступает одновременно в виде будильника и таймера
	
	self.status          = false;                       // true - работает, false - остановлен
	self.time            = 0;                           // Время, когда сработает будильник
	self.timeSet         = 1;                           // Через какое время будильник сработает(Каждые ...)
				         				                
	self.timePoint       = 0;                           // Время, когда будильник был остановлен или запущен
	self.timer           = 0;                           // время таймера, до последнего запуска
										                
	self.destroyed       = false;                       // Удалить после активации(true) или нет(false)
	self.destroyed_callback = false;
	self.func            = alarm_default_func         // функция, которая сработает при истечении времени
	self.loop            = false;	                    // true - повторять, false - исполнить один раз
	self.sync            = true;                        /* true - выполняется в шагах игры(время указывается в шагах), 
                                                         * false - в реальном времени(время указывается в секундах)
					      			                     */
										                
	self.repeating       = false;                       /* Если за время между вызовами alarm_update, 
						                                 * будильник мог произойти n раз, тогда и функция будет инициализирована n раз. 
						                                 * Работает только с sync=false и loop=true.
							                             */
	
	self.link			 = self;
	
	static set_name      = function(_argName)           { return alarm_set_name(self, _argName);           } // Устанавливает название будильника
	static set_sync      = function(_argSync, _argTime) { return alarm_set_sync(self, _argSync, _argTime); } // Устанавливаем тип будильника и время
	
	static set           = function(_argTime)           { return alarm_set_duration(self, _argTime);       } // Устанавливаем время
	static get           = function()                   { return alarm_get_difference(self);               } // Сколько осталось времени до срабатывания будильника
	
	static set_destroy   = function(_destroyed)         { return alarm_set_destroy(self, _destroyed);      } //
	static set_destroy_callback = function(_destroyed){return alarm_set_destroy_callback(self, _destroyed);}
	static set_loop      = function(_loop)              { self.loop = _loop;                               } //
	
	static get_lost      = function()                   { return alarm_get_lost(self);                     } //
	static get_duration  = function()                   { return alarm_get_duration(self);                 } //
	static get_progress  = function()                   { return alarm_get_progress(self);                 } //
	static get_done_time = function()                   { return alarm_get_done_time(self);                } //
	
	static set_data      = function(_data)              { return alarm_set_data(self, _data);              } //
	static get_data      = function()                   { return alarm_get_data();                         } //
	static set_func      = function(_callback)          { return alarm_set_func(self, _callback);          } // 
	static get_func      = function()                   { return alarm_get_func();                         } //
	
	static resume        = function()                   { return alarm_resume(self);                       } // Продолжить выполнение будильника
	static stop          = function()                   { return alarm_stop(self);                         } // Остановить будильник
	static replay        = function()                   { return alarm_replay(self);                       } // Перезапустить будильник
	
	static timer_get     = function()                   { return alarm_timer_get(self);                    } // Возвращает значение таймера
	static timer_clear   = function()                   { return alarm_timer_clear(self);                  } // Очистить таймер
	static timer_reset   = function(_argTime)           { return alarm_timer_reset(self, _argTime);        } // Очистить таймер и установить его значение
	
	static del           = function()                   { return alarm_delete(self);                       } // Удалить будильник
	
	static settings      = 
		function() { // гарантируем наличие глобальных переменных
		
			init_alarms();
			return method(
				undefined, function(_setting)           { return alarm_settings(self, _setting);           } //
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
			alarm_set_duration(_alarm, _value - __time);
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
