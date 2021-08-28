
//https://vk.com/clubgamemakerpro
/*
Параметры(Только для чтения):
	self - Возвратный идентификатор будильника
	name - имя будильника
	status - статус будильник, запущен(true) или остановлен(false*)
	time - Время, когда сработает будильник
	timeSet - промежуток, через который срабатывает будильник
	timePoint - время последнего изменения состояния будильника
	timer - время таймера, до последнего запуска
	sync - будильник делает отcчёт в шагах игры(true*) или в реальном времени(false)
	
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
	settings - установка параметров 
	
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
	
	
	if (argument_count > 0) {             // Если при создании были указны настройки в структуре
		_thisAlarm.settings(argument[0]); // то применяем их к ново-созданному будильнику
	}
	
	ds_map_add(__alarms, _thisAlarm.name, _thisAlarm);
	var _alarms_object = _alarms_objects[? self];
	if(_alarms_object == undefined){
		_alarms_object = ds_map_create();
		ds_map_add(_alarms_objects, self, _alarms_object);
	}
	
	ds_map_add(_alarms_object, _thisAlarm.name, _thisAlarm);
	
	return _thisAlarm; // Возвращаем ново-созданный будильник
}

function alarm_delete(_thisAlarm) {// Удаляет будильник
	if (is_string(_thisAlarm)) { _thisAlarm = alarm_find(_thisAlarm); if (is_undefined(_thisAlarm)) return undefined; };
	
	if(
	(_thisAlarm.destroyed_callback == 1) ||
	(_thisAlarm.destroyed_callback == 2 && _thisAlarm.status == true) || 
	(_thisAlarm.destroyed_callback == 3 && _thisAlarm.status == false)){
		with (_thisAlarm) {
			var _vfunc = _thisAlarm.func;
			with (self.link) _vfunc(other.data, other);
		}
	}else{
		if(is_method(_thisAlarm.destroyed_callback)){
			var _vfunc = _thisAlarm.destroyed_callback;
			with (self.link) _vfunc(other.data, other);
		}
	}
	
	var _alarms_object = _alarms_objects[? _thisAlarm.link];
	if(_alarms_object != undefined){
		ds_map_delete(_alarms_object, _thisAlarm.name);
	}
	
	ds_priority_delete_value(__alarmsSync, _thisAlarm);
	ds_priority_delete_value(__alarmsAsync, _thisAlarm);
	ds_map_delete(__alarms, _thisAlarm.name);
	delete _thisAlarm;
}

function alarm_exists(_thisAlarm) {// Проверяем на существование будильник по его имени
	if (is_string(_thisAlarm)) { _thisAlarm = alarm_find(_thisAlarm); if (is_undefined(_thisAlarm)) return undefined; };
	return !is_undefined(__alarms[? _thisAlarm]);
}

function alarm_find(name) {// Возвращает структуру будильника по его установленному имени
	return __alarms[? name];
}

function alarm_get_difference(_thisAlarm) {// Возвращает разницу от текущего времени до срабатывания будильника
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

function alarm_get_done_time(_thisAlarm) {// Возвращает время до срабатывания будильника
	if (is_string(_thisAlarm)) { _thisAlarm = alarm_find(_thisAlarm); if (is_undefined(_thisAlarm)) return undefined; };
	return (_thisAlarm.get_lost() == 0);
}

function alarm_get_duration(_thisAlarm) {
	if (is_string(_thisAlarm)) { _thisAlarm = alarm_find(_thisAlarm); if (is_undefined(_thisAlarm)) return undefined; };
	return _thisAlarm.timeSet;
}

function alarm_get_lost(_thisAlarm) {// Возвращает время до срабатывания будильника
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

function alarm_get_progress(_thisAlarm) {
	if (is_string(_thisAlarm)) { _thisAlarm = alarm_find(_thisAlarm); if (is_undefined(_thisAlarm)) return undefined; };
	with (_thisAlarm) {
		return ((self.timeSet - self.get_lost()) / self.timeSet);
	}
}

function alarm_replay(_thisAlarm) {// Перезапускает будильник
	if (is_string(_thisAlarm)) { _thisAlarm = alarm_find(_thisAlarm); if (is_undefined(_thisAlarm)) return undefined; };
	return _thisAlarm.resume().set(_thisAlarm.timeSet);
}

function alarm_resume(_thisAlarm) {// Запускает будильник
	if (is_string(_thisAlarm)) { _thisAlarm = alarm_find(_thisAlarm); if (is_undefined(_thisAlarm)) return undefined; };
	with (_thisAlarm) {
		if (!self.status) {
			if(self.timeSet>0){
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
	}
	return _thisAlarm;
}

function alarm_set_duration(_thisAlarm, _argTime=1) {// Устанавливаем время, через которое сработает будильник
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

function alarm_set_name(_thisAlarm, _argName) {// Устанавливаем название будильника. Поиск будьника через alarm_find(name)
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

function alarm_set_sync(_thisAlarm, _argSync = true, _argTime=1) {// Смена режим будильника и время срабатывания будильника
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

function alarm_stop(_thisAlarm) {// Останавливает будильник
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

function alarm_set_destroy(_thisAlarm, _destroyed = true) {
	if (is_string(_thisAlarm)) { _thisAlarm = alarm_find(_thisAlarm); if (is_undefined(_thisAlarm)) return undefined; };
	_thisAlarm.destroyed = _destroyed;
	
	return _thisAlarm;
}

function alarm_set_destroy_callback(_thisAlarm, _destroyed = true) {
	if (is_string(_thisAlarm)) { _thisAlarm = alarm_find(_thisAlarm); if (is_undefined(_thisAlarm)) return undefined; };
	_thisAlarm.destroyed_callback = _destroyed;
	
	return _thisAlarm;
}

function alarm_get_destroy_callback(_thisAlarm){
	return _thisAlarm.destroyed_callback;
}

function alarm_timer_clear(_thisAlarm) {// Обнуляем таймер будильника
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

function alarm_timer_get(_thisAlarm) {// Возвращает время таймера
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

function alarm_timer_reset(_thisAlarm, _time=0) {// Обнуляем таймер(В случае второго аргумента - устанавливаем значение)
	if (is_string(_thisAlarm)) { _thisAlarm = alarm_find(_thisAlarm); if (is_undefined(_thisAlarm)) return undefined; };
	with (_thisAlarm) {
		var _prestatus = self.status;
		self.stop();
		self.timer = _time;
		if (_prestatus) self.resume();
	}
	return _thisAlarm;
}

function alarm_is_playing(_alarm){
	return _alarm.status;
}

function alarm_is_stoped(_alarm){
	return !_alarm.status;
}

function alarm_is_sync(_alarm){
	return _alarm.sync;
}

function alarm_is_async(_alarm){
	return !_alarm.sync;
}

//Для работы со всеми будильниками
function alarms_all_stop() {// Остановить все будильники
	var _key = ds_map_find_first(__alarms);
	repeat ds_map_size(__alarms) {
		__alarms[? _key].stop();
		_key = ds_map_find_next(__alarms, _key);
	}
}

function alarms_all_resume() {// Возобновляем все будильники
	var _key = ds_map_find_first(__alarms);
	repeat ds_map_size(__alarms) {
		__alarms[? _key].resume();
		_key = ds_map_find_next(__alarms, _key);
	}
}

function alarms_all_delete() {// Удаляем все будильники
	var _key = ds_map_find_first(__alarms);
	var _alarm;
	repeat ds_map_size(__alarms) {
		_alarm = __alarms[? _key];
		_key = ds_map_find_next(__alarms, _key);
		_alarm.del();
	}
}

function alarms_count(){// Возвращает кол-во всех будильников
	return ds_map_size(__alarms);
}

function alarms_count_playing_sync(){// Возвращает кол-во всех запущенных синхронных будильников
	return ds_priority_size(__alarmsSync);
}

function alarms_count_playing_async(){// Возвращает кол-во всех запущенных асинхронных будильников
	return ds_priority_size(__alarmsAsync);
}

function alarms_count_sync(){
	var _alarms = ds_priority_create(), _alarm, count = 0;
	ds_priority_copy(_alarms, __alarmsSync);
	repeat ds_priority_size(_alarms){
		_alarm = ds_priority_delete_min(_alarms);
		count += alarm_is_sync(_alarm);
	}
	ds_priority_destroy(_alarms);
	return count;
}

function alarms_count_async(){
	var _alarms = ds_priority_create(), _alarm, count = 0;
	ds_priority_copy(_alarms, __alarmsAsync);
	repeat ds_priority_size(_alarms){
		_alarm = ds_priority_delete_min(_alarms);
		count += alarm_is_sync(_alarm);
	}
	ds_priority_destroy(_alarms);
	return count;
}

function alarms_count_playing(){// Возвращает кол-во всех запущенных будильников
	return alarms_count_playing_sync() + alarms_count_playing_async();
}

function alarms_count_stoped(){// Возвращает кол-во всех остановленных будильников
	return alarms_count() - alarms_count_playing();
}

function alarms_count_stoped_sync(){// Возвращает кол-во всех остановленных синхронных будильников
	return alarms_count() - alarms_count_playing_async();
}

function alarms_count_stoped_async(){// Возвращает кол-во всех остановленных асинхронных будильников
	return alarms_count() - alarms_count_playing_sync();
}

function alarms_foreach(callback, data = undefined){// Выполняется колбэк для всех будильников
	var _alarms = ds_map_values_to_array(__alarms), _alarm, result;
	for(var i=0; i<array_length(_alarms); i++){
		_alarm = _alarms[i];
		if(alarm_exists(_alarm)){
			result = callback(_alarm, data);
			if(result != undefined){return result;}
		}
	}
}

function alarms_foreach_playing_sync(callback, data = undefined){// Выполняется колбэк для всех запущенных синхронных будильников
	var _alarms = ds_priority_create(), _alarm, result;
	ds_priority_copy(_alarms, __alarmsSync);
	repeat ds_priority_size(_alarms){
		_alarm = ds_priority_delete_min(_alarms);
		result = callback(_alarm, data);
		if(result != undefined){ds_priority_destroy(_alarms); return result;}
	}
	ds_priority_destroy(_alarms);
}
	
function alarms_foreach_playing_async(callback, data = undefined){// Выполняется колбэк для всех запущенных асинхронных будильников
	var _alarms = ds_priority_create(), _alarm, result;
	ds_priority_copy(_alarms, __alarmsAsync);
	repeat ds_priority_size(_alarms){
		var _alarm = ds_priority_delete_min(_alarms);
		result = callback(_alarm, data);
		if(result != undefined){ds_priority_destroy(_alarms); return result;}
	}
	ds_priority_destroy(_alarms);
}

function alarms_foreach_playing(callback, data = undefined){// Выполняется колбэк для всех запущенных будильников
	var result;
	result = alarms_foreach_playing_sync(callback, data);
	if(result != undefined){return result;}
	result = alarms_foreach_playing_async(callback, data);
	if(result != undefined){return result;}
}

function alarms_foreach_stoped_sync(callback, data = undefined){// Выполняется колбэк для всех остановленных синхронных будильников
	var _alarms = ds_map_values_to_array(__alarms), _alarm, result;
	for(var i=0; i<array_length(_alarms); i++){
		_alarm = _alarms[i];
		if(alarm_exists(_alarm) && alarm_is_sync() && alarm_is_stoped()){
			result = callback(_alarm, data);
			if(result != undefined){return result;}
		}
	}
}

function alarms_foreach_stoped_async(callback, data = undefined){// Выполняется колбэк для всех остановленных асинхронных будильников
	var _alarms = ds_map_values_to_array(__alarms), _alarm, result;
	for(var i=0; i<array_length(_alarms); i++){
		_alarm = _alarms[i];
		if(alarm_exists(_alarm) && alarm_is_async() && alarm_is_stoped()){
			result = callback(_alarm, data);
			if(result != undefined){return result;}
		}
	}
}

function alarms_foreach_stoped(callback, data = undefined){// Выполняется колбэк для всех остановленных будильников
	var _alarms = ds_map_values_to_array(__alarms), _alarm, result;
	for(var i=0; i<array_length(_alarms); i++){
		_alarm = _alarms[i];
		if(alarm_exists(_alarm) && alarm_is_stoped()){
			result = callback(_alarm, data);
			if(result != undefined){return result;}
		}
	}
}

function alarms_get(){// Возвращает массив всех алармов
	return ds_map_values_to_array(__alarms);
}

function alarms_get_playing_sync(){// Возвращает массив запущенных синхронных будильников
	var array = [];
	var _alarms = ds_priority_create();
	ds_priority_copy(_alarms, __alarmsSync);
	repeat ds_priority_size(_alarms){
		var _alarm = ds_priority_delete_min(_alarms);
		array_push(array, _alarm);
	}
	ds_priority_destroy(_alarms);
	return array;
}

function alarms_get_playing_async(){// Возвращает массив запущенных асинхронных будильников
	var array = [];
	var _alarms = ds_priority_create();
	ds_priority_copy(_alarms, __alarmsAsync);
	repeat ds_priority_size(_alarms){
		var _alarm = ds_priority_delete_min(_alarms);
		array_push(array, _alarm);
	}
	ds_priority_destroy(_alarms);
	return array;
}

function alarms_get_playing(){// Возвращает массив запущенных будильников
	var array = [];
	
	var _alarms = ds_priority_create();
	ds_priority_copy(_alarms, __alarmsSync);
	repeat ds_priority_size(_alarms){
		var _alarm = ds_priority_delete_min(_alarms);
		array_push(array, _alarm);
	}
	ds_priority_destroy(_alarms);
	
	var _alarms = ds_priority_create();
	ds_priority_copy(_alarms, __alarmsAsync);
	repeat ds_priority_size(_alarms){
		var _alarm = ds_priority_delete_min(_alarms);
		array_push(array, _alarm);
	}
	ds_priority_destroy(_alarms);
	
	return array;
}

function alarms_get_stoped_sync(){// Возвращает массив остановленных синхронных будильников
	var array = [];
	var _alarms = ds_map_values_to_array(__alarms), _alarm;
	for(var i=0; i<array_length(_alarms); i++){
		_alarm = _alarms[i];
		if(alarm_exists(_alarm) && alarm_is_sync() && alarm_is_stoped()){
			array_push(array, _alarm);
		}
	}
	return array;
}

function alarms_get_stoped_async(){// Возвращает массив остановленных асинхронных будильников
	var array = [];
	var _alarms = ds_map_values_to_array(__alarms), _alarm;
	for(var i=0; i<array_length(_alarms); i++){
		_alarm = _alarms[i];
		if(alarm_exists(_alarm) && alarm_is_async() && alarm_is_stoped()){
			array_push(array, _alarm);
		}
	}
	return array;
}

function alarms_get_stoped(){// Возвращает массив остановленных будильников
	var array = [];
	var _alarms = ds_map_values_to_array(__alarms), _alarm;
	for(var i=0; i<array_length(_alarms); i++){
		_alarm = _alarms[i];
		if(alarm_exists(_alarm) && alarm_is_stoped()){
			array_push(array, _alarm);
		}
	}
	return array;
}

//Для работы с будильниками в пределах объекта
function alarms_count_object(object_or_struct = self) {// Возвращает кол-во будильников принадлежащих указанному объекту или структуре
	var	_alarms_object = _alarms_objects[? object_or_struct];
	if(_alarms_object != undefined){
		return ds_map_size(_alarms_object);	
	}
}

function alarms_count_object_playing_sync(object_or_struct = self){// Возвращает кол-во запущенных синхронных будильников принадлежащих указанному объекту или структуре
	var count = 0;
	var	_alarms_object = _alarms_objects[? object_or_struct];
	if(_alarms_object != undefined){
		
		var _alarms = ds_map_values_to_array(_alarms_object), _alarm;
		for(var i=0; i<array_length(_alarms); i++){
			_alarm = _alarms[i];
			if(alarm_exists(_alarm) && alarm_is_sync() && alarm_is_playing()){
				count++;
			}
		}
	}
	return count;
}

function alarms_count_object_playing_async(object_or_struct = self){// Возвращает кол-во запущенных асинхронных будильников принадлежащих указанному объекту или структуре
	var count = 0;
	var	_alarms_object = _alarms_objects[? object_or_struct];
	if(_alarms_object != undefined){
		
		var _alarms = ds_map_values_to_array(_alarms_object), _alarm;
		for(var i=0; i<array_length(_alarms); i++){
			_alarm = _alarms[i];
			if(alarm_exists(_alarm) && alarm_is_async() && alarm_is_playing()){
				count++;
			}
		}
	}
	return count;
}

function alarms_count_object_stoped_sync(object_or_struct = self){// Возвращает кол-во остановленных синхронных будильников принадлежащих указанному объекту или структуре
	var count = 0;
	var	_alarms_object = _alarms_objects[? object_or_struct];
	if(_alarms_object != undefined){
		
		var _alarms = ds_map_values_to_array(_alarms_object), _alarm;
		for(var i=0; i<array_length(_alarms); i++){
			_alarm = _alarms[i];
			if(alarm_exists(_alarm) && alarm_is_stoped() && alarm_is_sync()){
				count++;
			}
		}
	}
	return count;
}

function alarms_count_object_stoped_async(object_or_struct = self){// Возвращает кол-во остановленных асинхронных будильников принадлежащих указанному объекту или структуре
	var count = 0;
	var	_alarms_object = _alarms_objects[? object_or_struct];
	if(_alarms_object != undefined){
		
		var _alarms = ds_map_values_to_array(_alarms_object), _alarm;
		for(var i=0; i<array_length(_alarms); i++){
			_alarm = _alarms[i];
			if(alarm_exists(_alarm) && alarm_is_stoped() && alarm_is_async()){
				count++;
			}
		}
	}
	return count;
}

function alarms_count_object_playing(object_or_struct = self) {// Возвращает кол-во запущенных будильников принадлежащих указанному объекту или структуре
	var count = 0;
	var	_alarms_object = _alarms_objects[? object_or_struct];
	if(_alarms_object != undefined){
		
		var _alarms = ds_map_values_to_array(_alarms_object), _alarm;
		for(var i=0; i<array_length(_alarms); i++){
			_alarm = _alarms[i];
			if(alarm_exists(_alarm) && alarm_is_playing()){
				count++;
			}
		}
	}
	return count;
}

function alarms_count_object_stoped(object_or_struct = self) {// Возвращает кол-во остановленных будильников принадлежащих указанному объекту или структуре
var count = 0;
	var	_alarms_object = _alarms_objects[? object_or_struct];
	if(_alarms_object != undefined){
		
		var _alarms = ds_map_values_to_array(_alarms_object), _alarm;
		for(var i=0; i<array_length(_alarms); i++){
			_alarm = _alarms[i];
			if(alarm_exists(_alarm) && alarm_is_stoped()){
				count++;
			}
		}
	}
	return count;
}

function alarms_object_foreach(object_or_struct = self, callback, data = undefined) {// 
	var	_alarms_object = _alarms_objects[? object_or_struct];
	if(_alarms_object != undefined){
		var _alarms = ds_map_values_to_array(_alarms_object), _alarm, result;
		for(var i=0; i<array_length(_alarms); i++){
			_alarm = _alarms[i];
			if(alarm_exists(_alarm)){
				result = callback(_alarm, data);
				if(result != undefined){return result;}
			}
		}
		return false;
	}
}

function alarms_object_foreach_playing_sync(object_or_struct = self, callback, data = undefined){// 
	var	_alarms_object = _alarms_objects[? object_or_struct];
	if(_alarms_object != undefined){
		var _alarms = ds_map_values_to_array(_alarms_object), _alarm, result;
		for(var i=0; i<array_length(_alarms); i++){
			_alarm = _alarms[i];
			if(alarm_exists(_alarm) && alarm_is_playing(_alarm) && alarm_is_sync(_alarm)){
				result = callback(_alarm, data);
				if(result != undefined){return result;}
			}
		}
		return false;
	}
}

function alarms_object_foreach_playing_async(object_or_struct = self, callback, data = undefined){// 
	var	_alarms_object = _alarms_objects[? object_or_struct];
	if(_alarms_object != undefined){
		var _alarms = ds_map_values_to_array(_alarms_object), _alarm, result;
		for(var i=0; i<array_length(_alarms); i++){
			_alarm = _alarms[i];
			if(alarm_exists(_alarm) && alarm_is_playing(_alarm) && alarm_is_async(_alarm)){
				result = callback(_alarm, data);
				if(result != undefined){return result;}
			}
		}
		return false;
	}
}

function alarms_object_foreach_stoped_sync(object_or_struct = self, callback, data = undefined){// 
	var	_alarms_object = _alarms_objects[? object_or_struct];
	if(_alarms_object != undefined){
		var _alarms = ds_map_values_to_array(_alarms_object), _alarm, result;
		for(var i=0; i<array_length(_alarms); i++){
			_alarm = _alarms[i];
			if(alarm_exists(_alarm) && alarm_is_stoped(_alarm) && alarm_is_sync(_alarm)){
				result = callback(_alarm, data);
				if(result != undefined){return result;}
			}
		}
		return false;
	}
}

function alarms_object_foreach_stoped_async(object_or_struct = self, callback, data = undefined){// 
	var	_alarms_object = _alarms_objects[? object_or_struct];
	if(_alarms_object != undefined){
		var _alarms = ds_map_values_to_array(_alarms_object), _alarm, result;
		for(var i=0; i<array_length(_alarms); i++){
			_alarm = _alarms[i];
			if(alarm_exists(_alarm) && alarm_is_stoped(_alarm) && alarm_is_async(_alarm)){
				result = callback(_alarm, data);
				if(result != undefined){return result;}
			}
		}
		return false;
	}
}

function alarms_object_foreach_playing(object_or_struct = self, callback, data = undefined) {// 
	var	_alarms_object = _alarms_objects[? object_or_struct];
	if(_alarms_object != undefined){
		var _alarms = ds_map_values_to_array(_alarms_object), _alarm, result;
		for(var i=0; i<array_length(_alarms); i++){
			_alarm = _alarms[i];
			if(alarm_exists(_alarm) && alarm_is_playing(_alarm)){
				result = callback(_alarm, data);
				if(result != undefined){return result;}
			}
		}
		return false;
	}
}

function alarms_object_foreach_stoped(object_or_struct = self, callback, data = undefined) {// 
	var	_alarms_object = _alarms_objects[? object_or_struct];
	if(_alarms_object != undefined){
		var _alarms = ds_map_values_to_array(_alarms_object), _alarm, result;
		for(var i=0; i<array_length(_alarms); i++){
			_alarm = _alarms[i];
			if(alarm_exists(_alarm) && alarm_is_stoped(_alarm)){
				result = callback(_alarm, data);
				if(result != undefined){return result;}
			}
		}
		return false;
	}
}

function alarms_object_get(object_or_struct = self) {// 
	var	_alarms_object=_alarms_objects[?object_or_struct];
	if(_alarms_object !=undefined){
		return ds_map_values_to_array(_alarms_object);	
	}
}

function alarms_object_get_playing_sync(object_or_struct = self){// 
	var array = [];
	var	_alarms_object = _alarms_objects[? object_or_struct];
	if(_alarms_object != undefined){
		var _alarms = ds_map_values_to_array(_alarms_object), _alarm, result;
		for(var i=0; i<array_length(_alarms); i++){
			_alarm = _alarms[i];
			if(alarm_exists(_alarm) && alarm_is_playing(_alarm) && alarm_is_sync(_alarm)){
				array_push(array, _alarm);
			}
		}
		return false;
	}
	return array;
}

function alarms_object_get_playing_async(object_or_struct = self){// 
	var array = [];
	var	_alarms_object = _alarms_objects[? object_or_struct];
	if(_alarms_object != undefined){
		var _alarms = ds_map_values_to_array(_alarms_object), _alarm, result;
		for(var i=0; i<array_length(_alarms); i++){
			_alarm = _alarms[i];
			if(alarm_exists(_alarm) && alarm_is_playing(_alarm) && alarm_is_async(_alarm)){
				array_push(array, _alarm);
			}
		}
		return false;
	}
	return array;
}

function alarms_object_get_stoped_sync(object_or_struct = self){// 
	var array = [];
	var	_alarms_object = _alarms_objects[? object_or_struct];
	if(_alarms_object != undefined){
		var _alarms = ds_map_values_to_array(_alarms_object), _alarm, result;
		for(var i=0; i<array_length(_alarms); i++){
			_alarm = _alarms[i];
			if(alarm_exists(_alarm) && alarm_is_stoped(_alarm) && alarm_is_sync(_alarm)){
				array_push(array, _alarm);
			}
		}
		return false;
	}
	return array;
}

function alarms_object_get_stoped_async(object_or_struct = self){// 
	var array = [];
	var	_alarms_object = _alarms_objects[? object_or_struct];
	if(_alarms_object != undefined){
		var _alarms = ds_map_values_to_array(_alarms_object), _alarm, result;
		for(var i=0; i<array_length(_alarms); i++){
			_alarm = _alarms[i];
			if(alarm_exists(_alarm) && alarm_is_stoped(_alarm) && alarm_is_async(_alarm)){
				array_push(array, _alarm);
			}
		}
		return false;
	}
	return array;
}

function alarms_object_get_playing(object_or_struct = self) {// 
	var array = [];
	var	_alarms_object = _alarms_objects[? object_or_struct];
	if(_alarms_object != undefined){
		var _alarms = ds_map_values_to_array(_alarms_object), _alarm, result;
		for(var i=0; i<array_length(_alarms); i++){
			_alarm = _alarms[i];
			if(alarm_exists(_alarm) && alarm_is_playing(_alarm)){
				array_push(array, _alarm);
			}
		}
		return false;
	}
	return array;
}

function alarms_object_get_stoped(object_or_struct = self) {// 
	var array = [];
	var	_alarms_object = _alarms_objects[? object_or_struct];
	if(_alarms_object != undefined){
		var _alarms = ds_map_values_to_array(_alarms_object), _alarm, result;
		for(var i=0; i<array_length(_alarms); i++){
			_alarm = _alarms[i];
			if(alarm_exists(_alarm) && alarm_is_stoped(_alarm)){
				array_push(array, _alarm);
			}
		}
		return false;
	}
	return array;
}

function alarms_object_resume_all(object_or_struct=self){// 
	var	_alarms_object=_alarms_objects[?object_or_struct];
	if(_alarms_object !=undefined){
		var _alarm_name = ds_map_find_first(_alarms_object);
		var _alarm;
		repeat ds_map_size(_alarms_object) {
			_alarm = _alarms_object[? _alarm_name];
			_alarm_name = ds_map_find_next(_alarms_object, _alarm_name);
			_alarm.resume();
		}
		return true;
	}
}

function alarms_object_stop_all(object_or_struct=self){// 
	var	_alarms_object=_alarms_objects[?object_or_struct];
	if(_alarms_object !=undefined){
		var _alarm_name = ds_map_find_first(_alarms_object);
		var _alarm;
		repeat ds_map_size(_alarms_object) {
			_alarm = _alarms_object[? _alarm_name];
			_alarm_name = ds_map_find_next(_alarms_object, _alarm_name);
			_alarm.stop();
		}
		return true;
	}
}

function alarms_object_delete_all(object_or_struct=self){// 
	var	_alarms_object=_alarms_objects[?object_or_struct];
	if(_alarms_object !=undefined){
		var _alarm_name = ds_map_find_first(_alarms_object);
		var _alarm;
		repeat ds_map_size(_alarms_object) {
			_alarm = _alarms_object[? _alarm_name];
			_alarm_name = ds_map_find_next(_alarms_object, _alarm_name);
			_alarm.del();
		}
		return true;
	}
}
