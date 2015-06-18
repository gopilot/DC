function getParameter(name) {
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(location.search);
    return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}

jQuery(function($){
	$('input, textarea').typeWatch({
		event: 'typingDone',
		wait: 750
	});

	var session, user_id, user;
	$.get('https://api.gopilot.org/users/find_incomplete/'+getParameter('token'), function(data, status){
		if(!data || !data.session || !data.user){
			$('.error-container').addClass("shown")
			return console.log("ERROR", data)
		}
		document.cookie = "session="+data.session;
		session = data.session;
		user = {
			name: data.user.name,
			email: data.user.email,
			id: data.user.id
		};
		$('.js-name').val( user.name );
		$('.js-email').val( user.email );
		user_id = user.id;
	}).error(function(data){
		$('.error-container').addClass("shown")
		return console.log("ERROR", data)
	});

	var validators = {
		"name": /^[a-zA-Z\\s]+ /i,
		"phone": /[0-9-\(\)]{10,12}/,
		"email": /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}\b/i,
		"experience": /[0-9]*/,
		"date": /[0-9]{2}\/[0-9]{2}\/[0-9]{4}/,
		"password": /.{8,}/
	}

	function validateInput(elem){
		$(elem).siblings('.status').removeClass('pe-7s-check pe-7s-close-circle');
		if( $(elem).val().length > 0) {
			var type = $(elem).data('validation');
			var field = $(elem).attr('name');
			console.log("Checking", $(elem).val(), validators[ type ], $(elem).val().match( validators[ type ] ))
			if( $(elem).val().match( validators[ type ] ) ){
				
				$(elem).siblings('.status').addClass('pe-7s-check');
			}else{
				$(elem).siblings('.status').addClass('pe-7s-close-circle');
				
				if( $('.error-messages .message.'+field).length )
					$('.error-messages .message.'+field).text( $(elem).data("error") );
				else
					$('.error-messages').append("<div class='message "+field+"'>"+$(elem).data("error")+"</div>");
			}
		}
		$('.error-messages .message.'+field).remove()
	}

	validateInput( 'input.js-name' );
	validateInput( 'input.js-email' );

	$('input[required]').on('typingDone', function(evt){
		validateInput(this);
	});
	$('input[required]').on('blur', function(evt){
		validateInput(this);
	});

	$('.toggle-button').on('click', function(evt){
		var field = $(this).parent().attr('name')

		$(this).siblings().removeClass('selected');
		$(this).toggleClass('selected');

		if( field == "has_experience"){
			if( $(this).attr('value') == "1"){
				console.log("remove hidden")
				$('.input-container.experience').removeClass('hidden');
			}
			else{
				console.log("add hidden", $(this).attr('value'))
				$('.input-container.experience').addClass('hidden')
			}
		}
		$('.error-messages .message.'+field).remove()
	});

	function makeUser(){
		var user = {};
		$('.toggle-group').each(function(index){
			console.log(index);
			var field = $(this).attr('name');
			if( $(this).children(".selected").length ){
				user[ field ] = $(this).children(".selected").attr('value');
			}else{
				if( $('.error-messages .message.'+field).length )
					$('.error-messages .message.'+field).text( $(this).data("error") );
				else
					$('.error-messages').append("<div class='message "+field+"'>"+$(this).data("error")+"</div>");
			}
		});	
		$('input, textarea').each(function(index){
			var field = $(this).attr('name');
			var type = $(this).data('validation')

			if( $(this).val().match( validators[ type ] ) || ! $(this).attr('required') ){
				$(this).siblings('.status').addClass('pe-7s-check');
				user[ field ] = $(this).val()
			}else{
				$(this).siblings('.status').addClass('pe-7s-close-circle');
				if( $('.error-messages .message.'+field).length )
					$('.error-messages .message.'+field).text( $(this).data("error") );
				else
					$('.error-messages').append("<div class='message "+field+"'>"+$(this).data("error")+"</div>");
			}
		});

		user[ 'notes' ] = {}
		user[ 'notes' ][PILOT_EVENT_ID] = user[ 'event_notes' ]

		user[ 'has_experience' ] = user['has_experience'] === "1" || (user['has_experience'] && user['has_experience'].toLowerCase() == "false");

		delete user[ 'event_notes' ];

		return user;
	}

	function checkFields(user){
		return user[ 'name' ] &&
				user['email'] &&
				user['gender'] &&
				user['birth_date'] &&
				user['grade'] &&
				user['phone'] &&
				user['emergency_name'] &&
				user['emergency_email'] &&
				user['emergency_phone'] &&
				user['emergency_email'] &&
				(user['has_experience'] || user['has_experience'] === false) &&
				(user['has_experience'] ? user['experience_years'] : true) &&
				user['shirt_type'] &&
				user['shirt_size'] &&
				user['password'];
	}
	var submitTimer;
	function putUser( user ){
		$.ajax({
			url: "https://api.gopilot.org/users/"+user_id,
			data: JSON.stringify(user),
			type: 'PUT',
			contentType: "application/json",
			dataType: "json",
			beforeSend: function(xhr){xhr.setRequestHeader('session', session);},
		}).error(function( err ){
			console.log("ERROR!", err);
			$('.error-container').addClass("shown");
		}).done(function( data ){
			console.log("DONE!!!", data);
			clearTimeout(submitTimer);
			window.location = "/confirmation.html"
		});
	}

	$('.js-submit').on('click', function(evt){
		$('.error-messages').children().remove()
		submitTimer = setTimeout(function(){
			$('.error-container').addClass("shown");
		}, 10*1000);
		user = makeUser();
		if( checkFields( user )  ){
			delete user[ 'confirm_password' ]

			console.log(user);
			putUser( user )
		}else{
			console.log("error", user);
			clearTimeout(submitTimer);
			$('i.status:not(.pe-7s-check)').addClass('pe-7s-close-circle');
		}
	});
});