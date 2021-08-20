//Синхронные и асинхронные будильники V3.1

//https://vk.com/clubgamemakerpro
//Асинхронные будильники отличаются от синхронных, тем что не зависят от fps
//Колбэк - это функция, которая произойдёт при активации будильника
//Синхронные будильники задаются в шагах игры, асинхронные в милисекундах(в секунде - 1000 милисекунд)

globalvar _alarms, _alarmsSync, _alarmsAsync, _minSync, _minAsync, _time, classAlarm;
_alarms=ds_map_create();//Все будильники
_alarmsSync=ds_priority_create();//Активные синхронные будильники
_minSync=0;//Следующий синхронный будильник(Время)
_alarmsAsync=ds_priority_create();//Асинхронные синхронные будильники
_minAsync=0;//Следующий асинхронный будильник(Время)
_time=0;//Кол-во итераций alarm_update
	
//Создаём "Класс" будильника:
classAlarm = function() constructor{//Выступает одновременно в виде будильника и таймера
	status = false; //true - Работает, false - остановлен
	time = 0; //Время, когда сработает будильник
	timeSet = 0; //Через какое время будильник сработает(Каждые ...)
		
	timePoint = 0; //Время, когда будильник был остановлен или запущен
	timer = 0; //время таймера, до последнего запуска
		
	destroyed=false;//Удалить после активации(true) или нет(false)
	func = function(){};//функция, которая сработает при истечении времени
	loop = false;	//  true - повторять, false - исполнить один раз
	sync = true;	/*  true - выполняется в шагах игры(время указывается в шагах), 
						false - в реальном времени(время указывается в секундах)*/
							
	repeating = false;/*Если за время между вызовами alarm_update, 
						будильник мог произойти n раз, тогда и функция будет инициализирована n раз. 
						Работает только с sync=false и loop=true.*/
	
	set_name = function(argName){return alarm_set_name(this, argName);}//Устанавливает название будильника
	set_sync = function(argSync, argTime){return alarm_set_sync(this, argSync, argTime);}//Устанавливаем тип будильника и время
	
	set = function(argTime){return alarm_set_duration(this, argTime);}//Устанавливаем время
	get = function(){return alarm_get_difference(this);}//Сколько осталось времени до срабатывания будильника
	
	set_destroy = function(destroyed){return alarm_set_destroy(this, destroyed);}//
	set_loop = function(){}
	set_sync = function(){}
	
	get_lost = function(){return alarm_get_lost(this);}
	get_duration = function(){return alarm_get_duration(this);}
	get_progress = function(){return alarm_get_progress(this);}
	get_done_time = function(){return alarm_get_done_time(this);}
	
	set_data = function(data){return alarm_set_data(this, data);}
	get_data = function(){return alarm_get_data();}//
	set_done = function(callback){return alarm_set_done(this, callback);}
	get_done = function(){return alarm_get_done();}//
	
	resume = function(){return alarm_resume(this);}//Продолжить выполнение будильника
	stop = function(){return alarm_stop(this);}//Остановить будильник
	replay = function(){return alarm_replay(this);}//Перезапустить будильник
	
	timer_get = function(){return alarm_timer_get(this);}//Возвращает значение таймера
	timer_clear = function(){return alarm_timer_clear(this);}//Очистить таймер
	timer_reset = function(argTime){return alarm_timer_reset(this, argTime);}//Очистить таймер и установить его значение
	
	del = function(){return alarm_delete(this);}//Удалить будильник
		
	settings = function(setting){//Функция для установки настроек будильника
		return alarm_settings(this, setting);
	};
}

function alarm_settings(_alarm, _settings){
	var keysUp=variable_struct_get_names(_settings);
	
	var key, value;
	for(var i=0; i<array_length(keysUp); i++){
		key = keysUp[i];
		value = variable_struct_get(_settings, keysUp[i]);
		
		switch(key){
			case "status":{
				if(value){
					alarm_resume(_alarm);
				}else{
					alarm_stop(_alarm);
				}
				break;
			}
			case "duration":{
				alarm_set_duration(_alarm, value);
				break;
			}
			case "time":{
				alarm_set_duration(_alarm, value - _time);
				break;
			}
			case "timeSet":{
				_alarm.timeSet=max(0, value);
				break;
			}
			case "sync":{
				alarm_set_sync(_alarm, value);
				break;
			}
			case "name":{
				alarm_set_name(_alarm, value);
				break;
			}
			default: variable_struct_set(_alarm, key, value );
		}
	}
	array_resize(keysUp, 0);
	
	return _alarm;
}
