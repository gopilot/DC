jQuery(function($){
	$('input, textarea').typeWatch({
		event: 'typingDone',
		wait: 750
	});

	var validators = {
		"name": /^[a-zA-Z\\s]+ /i,
		"phone": /[0-9-\(\)]{10,12}/,
		"email": /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}\b/i,
		"experience": /[0-9]{1,2}/,
		"date": /[0-9]{2}\/[0-9]{2}\/[0-9]{2}/,
		"password": /.{8,}/
	}

	var user = {};

	function validateInput(elem){
		$(elem).siblings('.status').removeClass('pe-7s-check pe-7s-close-circle')
		if( $(elem).val().length > 0) {
			var type = $(elem).data('validation');
			var field = $(elem).attr('name');
			console.log("Checking", $(elem).val(), validators[ type ], $(elem).val().match( validators[ type ] ))
			if( $(elem).val().match( validators[ type ] ) ){
				user[ field ] = $(elem).val()
				$(elem).siblings('.status').addClass('pe-7s-check');
			}else{
				user[ field ] = null;
				$(elem).siblings('.status').addClass('pe-7s-close-circle')
			}
			
			if(field == "confirm_password" && user['password'] && $(elem).val() != user['password']){
				$(elem).siblings('.status').removeClass('pe-7s-check');
				$(elem).siblings('.status').addClass('pe-7s-close-circle');
			}
		}else{
			user[ field ] = null;
		}
	}

	$('input[required], textarea[required]').on('typingDone', function(evt){
		validateInput(this);
	});
	$('input[required], textarea[required]').on('blur', function(evt){
		validateInput(this);
	});

	$('.toggle-button').on('click', function(evt){
		var field = $(this).parent().attr('name')

		$(this).siblings().removeClass('selected');
		$(this).toggleClass('selected');

		user[ field ] = $(this).attr('value');

		if( field == "has_experience"){
			if( $(this).attr('value') == "1"){
				console.log("remove hidden")
				$('.input-container.skills').removeClass('hidden');
			}
			else{
				console.log("add hidden", $(this).attr('value'))
				$('.input-container.skills').addClass('hidden')
			}
		}
		
	});

	function checkFields(user){
		return user[ 'name' ] &&
				user['email'] &&
				user['gender'] &&
				user['phone'] &&
				user['password'] &&
				user['title'] &&
				user['company'] &&
				user['profiles'] &&
				user['has_experience'] &&
				(user['has_experience']=="1" ? user['skills'] : true) &&
				user['shirt_type'] &&
				user['shirt_size'];
	}

	function register( user ){
		$.ajax({
			url: "https://api.gopilot.org/events/"+PILOT_EVENT_ID+"/register/mentor",
			data: JSON.stringify(user),
			type: 'POST',
			contentType: "application/json",
			dataType: "json"
		}).done(function( data ){
			console.log("DONE!!!", data);
			window.location = "/confirmation.html"
		});
	}

	$('.js-submit').on('click', function(evt){
		if( checkFields( user )  ){
			delete user[ 'confirm_password' ]

			user[ 'dietary' ] = $('.js-dietary').val();
			user[ 'notes' ] = {}
			user[ 'notes' ][PILOT_EVENT_ID] = $('.js-other').val()
			user['has_experience'] = user['has_experience'] == "1"
			
			console.log(user);
			register( user )
		}else{
			console.log("error", user)
			$('i.status:not(.pe-7s-check)').addClass('pe-7s-close-circle');	
		}
	});
});