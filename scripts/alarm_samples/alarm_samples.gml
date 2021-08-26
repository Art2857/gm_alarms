
// Синхронный будильник
function alarm_sync(_time, _callback, _data) {
	return alarm_create({func: _callback, data: _data, destroyed: true}).resume().set(_time);
}
// https://vk.com/clubgamemakerpro

// Асинхронный будильник
function alarm_async(_time, _callback, _data) {
	return alarm_create({func: _callback, sync: false, destroyed: true, data: _data}).resume().set(_time);
}
// https://vk.com/clubgamemakerpro

// Синхронный зацикленный будильник
function alarm_loop_sync(_time, _callback, _data) {
	return alarm_create({func: _callback, loop: true, data: _data}).resume().set(_time);
}
// https://vk.com/clubgamemakerpro

// Асинхронный зацикленный будильник
function alarm_loop_async(_time, _callback, _data) {
	return alarm_create({func: _callback, loop: true, sync: false, data: _data}).resume().set(_time);
}
// https://vk.com/clubgamemakerpro

// Синхронный зацикленный будильник с повторениями(Если между alarm_update будильник мог сработать несколько раз, то он срабатывает несколько раз...)
function alarm_repeat_sync(_time, _callback, _data) {
	return alarm_create({func: _callback, data: _data, loop: true, sync: true, repeating: true}).resume().set(_time);
}
// https://vk.com/clubgamemakerpro

// Асинхронный зацикленный будильник с повторениями(Если между alarm_update будильник мог сработать несколько раз, то он срабатывает несколько раз...)
function alarm_repeat_async(_time, _callback, _data) {
	return alarm_create({func: _callback, data: _data, loop: true, sync: false, repeating: true}).resume().set(_time);
}
// https://vk.com/clubgamemakerpro

// Временный синхронный зацикленный будильник
function alarm_limit_sync(_time, _limit, _callback, _data, _callback_end, _data_end) {
	var _alarm_loop = alarm_loop_sync(_time,
	function(_data, _this) {
		if (_this.time < _this[$ "alarm_limit"].time) {
			_data.callback(_data.data, _this[$ "alarm_limit"], _this);
		}
	}, {callback: _callback, data: _data});
	
	_alarm_loop[$ "alarm_limit"] = alarm_sync(_limit + 1, 
		function(_data) {
			if (alarm_exists(_data.alarm_loop)) {
				if (is_method(_data.callback_end)) _data.callback_end(_data.data_end);
			}
			alarm_delete(_data.alarm_loop);
		}, {alarm_loop: _alarm_loop, callback_end: _callback_end, data_end: _data_end})
		.set_destroy(true).set_destroy_callback(true);
		
	return _alarm_loop[$ "alarm_limit"];
}
// https://vk.com/clubgamemakerpro

// Временный асинхронный зацикленный будильник
function alarm_limit_async(_time, _limit, _callback, _data, _callback_end, _data_end) {
	var _alarm_loop = alarm_loop_async(_time,
	function(_data, _this) {
		if (_this.time < _this[$ "alarm_limit"].time) {
			_data.callback(_data.data, _this[$ "alarm_limit"], _this);
		}
	}, {callback: _callback, data: _data});
	
	_alarm_loop[$ "alarm_limit"] = alarm_async(_limit + 1, 
		function(_data) {
			if (alarm_exists(_data.alarm_loop)) {
				if (is_method(_data.callback_end)) _data.callback_end(_data.data_end);
			}
			alarm_delete(_data.alarm_loop);
		}, {alarm_loop: _alarm_loop, callback_end: _callback_end, data_end: _data_end})
		.set_destroy(true).set_destroy_callback(true);
		
	return _alarm_loop[$ "alarm_limit"];
}
// https://vk.com/clubgamemakerpro

// Временный синхронный зацикленный будильник c повторением
function alarm_limit_repeat_sync(_time, _limit, _callback, _data, _callback_end, _data_end) {
	var _alarm_loop = alarm_repeat_sync(_time,
	function(_data, _this) {
		if (_this.time < _this[$ "alarm_limit"].time) {
			_data.callback(_data.data, _this[$ "alarm_limit"], _this);
		}
	}, {callback: _callback, data: _data});
	
	_alarm_loop[$ "alarm_limit"] = alarm_sync(_limit + 1, 
		function(_data) {
			if (alarm_exists(_data.alarm_loop)) {
				if (is_method(_data.callback_end)) _data.callback_end(_data.data_end);
			}
			alarm_delete(_data.alarm_loop);
		}, {alarm_loop: _alarm_loop, callback_end: _callback_end, data_end: _data_end})
		.set_destroy(true).set_destroy_callback(true);
		
	return _alarm_loop[$ "alarm_limit"];
}
// https://vk.com/clubgamemakerpro

// Временный асинхронный зацикленный будильник c повторением
function alarm_limit_repeat_async(_time, _limit, _callback, _data, _callback_end, _data_end) {
	var _alarm_loop = alarm_repeat_async(_time,
	function(_data, _this) {
		if (_this.time < _this[$ "alarm_limit"].time) {
			_data.callback(_data.data, _this[$ "alarm_limit"], _this);
		}
	}, {callback: _callback, data: _data});
	
	_alarm_loop[$ "alarm_limit"] = alarm_async(_limit + 1, 
		function(_data) {
			if (alarm_exists(_data.alarm_loop)) {
				if (is_method(_data.callback_end)) _data.callback_end(_data.data_end);
			}
			alarm_delete(_data.alarm_loop);
		}, {alarm_loop: _alarm_loop, callback_end: _callback_end, data_end: _data_end})
		.set_destroy(true).set_destroy_callback(true);
		
	return _alarm_loop[$ "alarm_limit"];
}
// https://vk.com/clubgamemakerpro


function alarm_limit_delete(_alarm_limit) {
	alarm_delete(_alarm_limit[$ "alarm_loop"]);
	alarm_delete(_alarm_limit);
}
function alarm_limit_stop(_alarm_limit) {
	alarm_stop(_alarm_limit[$ "alarm_loop"]);
	alarm_stop(_alarm_limit);
}
function alarm_limit_resume(_alarm_limit) {
	alarm_resume(_alarm_limit[$ "alarm_loop"]);
	alarm_resume(_alarm_limit);
}
