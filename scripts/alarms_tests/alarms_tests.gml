
// test-f
function test(_expr, _mess="") {
	if (!_expr) show_error(true, _mess);	
}

function alarm_test(){
	
	alarm_async(60, function(){
		
		show_debug_message("text1");
			alarm_sync(60, function(){
		
			show_debug_message("text2");
				alarm_limit_sync(60, 600, function(){
		
				show_debug_message("text3");
					alarm_limit_async(600, 6000, function(){
		
					show_debug_message("text4");
		
				});
			});
		});
	});
	
}