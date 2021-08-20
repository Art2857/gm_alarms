

//Синхронный будильник
function alarm_sync(time, callback, data){
	return alarm_create({func: callback, data: data, destroyed: true}).resume().set(time);
}
//https://vk.com/clubgamemakerpro

//Асинхронный будильник
function alarm_async(time, callback, data){
	return alarm_create({func: callback, sync: false, destroyed: true, data: data}).resume().set(time);
}
//https://vk.com/clubgamemakerpro

//Синхронный зацикленный будильник
function alarm_loop_sync(time, callback, data){
	return alarm_create({func: callback, loop: true, data: data}).resume().set(time);
}
//https://vk.com/clubgamemakerpro

//Асинхронный зацикленный будильник
function alarm_loop_async(time, callback, data){
	return alarm_create({func: callback, loop: true, sync: false, data: data}).resume().set(time);
}
//https://vk.com/clubgamemakerpro

//Синхронный зацикленный будильник с повторениями(Если между alarm_update будильник мог сработать несколько раз, то он срабатывает несколько раз...)
function alarm_repeat_sync(time, callback, data){
	return alarm_create({func: callback, data: data, loop: true, sync: true, repeating: true}).resume().set(time);
}
//https://vk.com/clubgamemakerpro

//Асинхронный зацикленный будильник с повторениями(Если между alarm_update будильник мог сработать несколько раз, то он срабатывает несколько раз...)
function alarm_repeat_async(time, callback, data){
	return alarm_create({func: callback, data: data, loop: true, sync: false, repeating: true}).resume().set(time);
}
//https://vk.com/clubgamemakerpro

//Временный синхронный зацикленный будильник
function alarm_limit_sync(time, limit, callback, data, callback_end, data_end){
	var alarm_loop=alarm_loop_sync(time, callback, data);
	alarm_loop[$"alarm_stoped"]=alarm_sync(limit, 
		function(data){
			if alarm_exists(data.alarm_loop){
				if(is_method(data.callback_end)){data.callback_end(data.data_end);}
			}
			alarm_delete(data.alarm_loop);
		}, {alarm_loop: alarm_loop, callback_end: callback_end, data_end: data_end});
	return alarm_loop;
}
//https://vk.com/clubgamemakerpro

//Временный асинхронный зацикленный будильник
function alarm_limit_async(time, limit, callback, data, callback_end, data_end){
	var alarm_loop=alarm_loop_async(time, callback, data);
	alarm_loop[$"alarm_stoped"]=alarm_async(limit, 
		function(data){
			if alarm_exists(data.alarm_loop){
				if(is_method(data.callback_end)){data.callback_end(data.data_end);}
			}
			alarm_delete(data.alarm_loop);
		}, {alarm_loop: alarm_loop, callback_end: callback_end, data_end: data_end});
	return alarm_loop;
}
//https://vk.com/clubgamemakerpro

//Временный синхронный зацикленный будильник c повторением
function alarm_limit_repeat_sync(time, limit, callback, data, callback_end, data_end){
	var alarm_loop=alarm_repeat_sync(time, callback, data);
		alarm_loop[$"alarm_stoped"]=alarm_sync(limit, 
			function(data){
				if alarm_exists(data.alarm_loop){
					if(is_method(data.callback_end)){data.callback_end(data.data_end);}
				}
				alarm_delete(data.alarm_loop);
			}, {alarm_loop: alarm_loop, callback_end: callback_end, data_end: data_end});
	return alarm_loop;
}
//https://vk.com/clubgamemakerpro

//Временный асинхронный зацикленный будильник c повторением
function alarm_limit_repeat_async(time, limit, callback, data, callback_end, data_end){
	var alarm_loop=alarm_repeat_async(time, callback, data);
	alarm_loop[$"alarm_stoped"]=alarm_async(limit, 
		function(data){
			if alarm_exists(data.alarm_loop){
				if(is_method(data.callback_end)){data.callback_end(data.data_end);}
			}
			alarm_delete(data.alarm_loop);
		}, {alarm_loop: alarm_loop, callback_end: callback_end, data_end: data_end});
	return alarm_loop;
}
//https://vk.com/clubgamemakerpro


function alarm_limit_delete(alarm_limit){
	alarm_delete(alarm_limit[$"alarm_stoped"]);
	alarm_delete(alarm_limit);
}
function alarm_limit_stop(alarm_limit){
	alarm_stop(alarm_limit[$"alarm_stoped"]);
	alarm_stop(alarm_limit);
}
function alarm_limit_resume(alarm_limit){
	alarm_resume(alarm_limit[$"alarm_stoped"]);
	alarm_resume(alarm_limit);
}