#= require "_helper"

# requirejs makes life a lot easier when dealing with more than one
# javascript file and any sort of dependencies, and loads faster.

# for more info on require config, see http://requirejs.org/docs/api.html#config
require.config(
	paths:
		'jquery': 'jquery'
)

require ['jquery'], ($) ->
	#console.log 'scripts loaded (via assets/js/main.coffee)'
	# paymentsServer = "http://localhost:5000/"
	
	# Touchscreen devices
	if /(iPad|iPhone|iPod|Android)/g.test navigator.userAgent 
		console.log "Touch!"
		$('.item').addClass 'show-overlay'
		$('#js-checkoutButton').addClass 'show-wide'


	paymentsServer = "http://payments.gopilot.org/"
	fireformPage = "http://fireform.org/list/152/DC_Shirts"
	

	price =
		ladies: 15
		unisex: 15
		hoodie: 30

	total = 0

	toggled = 
		ladies: false
		unisex: false
		hoodie: false

	generateDescription = () ->
		cart = []
		if toggled.ladies
			cart.push "Ladies' T-Shirt"
		if toggled.hoodie
			cart.push "Unisex Hoodie"
		if toggled.unisex
			cart.push "Unisex T-Shirt"
		return cart.join ", "

	generateSizes = () ->
		sizes = []
		if toggled.ladies
			sizes.push $('#ladies').prev().val()+" Ladies' T-Shirt"
		if toggled.hoodie
			sizes.push $('#hoodie').prev().val()+" Hoodie"
		if toggled.unisex
			sizes.push $('#unisex').prev().val()+" Unisex T-Shirt"
		return sizes.join ", "

	
	stripeKey = "pk_live_BXRjo7MBwBvPSNM1338ZQVj3"
	stripeKey = "pk_test_bVNI8WnLVJlwNySLMliWPRjW" if window.location.hostname == 'localhost'
	
	handler = StripeCheckout.configure(
		key: stripeKey
		image: "/img/logo_square.png"
		token: (token, args) ->
			console.log "stripe callback", token
			$.post(paymentsServer, {
				stripeToken: token.id
				ladies: toggled.ladies.toString()
				unisex: toggled.unisex.toString()
				hoodie: toggled.hoodie.toString()
				total: total
				livePayments: "true"
				email: $('#emailField').val()
			}, (charge, status) ->
				console.log 'post callback', status
				if status == "success"
					$('#orderField').val generateSizes()
					$('#totalField').val total
					$('#paidField').val 'true'
					$('#stripeField').val charge
					$('#js-submitForm').click();
				else
					console.error "Error!", charge, status 
					alert "Error submitting payment: "+charge 
			)
	)
	console.log $('#checkoutForm')
	new Fireform '#checkoutForm', fireformPage, {
		emailNotification: 'peter@gopilot.org',
		emailConfirmationName: 'hello!',
		emailConfirmationSubject: 'Order made!',
		emailConfirmationBodyText: 'lalalala',
		callback: (err, val) ->
			alert 'checkout callback '+val
			checkout = $('#js-orderButton')
			text = checkout.html()
			color = checkout.css 'background'
			checkout.html("<i class='fa fa-check'></i> Order Sent!");
			checkout.css('background', '#7fc028')
			setTimeout () ->
				checkout.html(text);
				checkout.css('background', color)
				$('#popup').removeClass 'shown'
				$('.item').removeClass 'selected'
			, 2000
	}
	$('.item').click (event) ->
		$(this).toggleClass 'selected'
		$(this).children('.check').toggleClass 'visible'
		$(this).prev().toggleClass 'visible'
		itemName = $(this).attr('id')
		if toggled[itemName]
			total -= price[itemName]
		else
			total += price[itemName]
		
		toggled[itemName] = !toggled[itemName]
		$('.js-price').html "$"+total.toFixed(2)
		return false

	$('#nameField').focusout (event) ->
		if !$(this).val()
			return $('#nameGroup').addClass 'has-error'
		else
			$('#nameGroup').removeClass 'has-error'

	$('#emailField').focusout (event) ->
		if !$(this).val()
			return $('#emailGroup').addClass 'has-error'
		else
			$('#emailGroup').removeClass 'has-error'

	$('#left-button').click (event) ->
		# Validation
		if !(toggled.ladies || toggled.unisex || toggled.hoodie)
			return alert("You need to pick at least one item!")
		if !$('#nameField').val()
			return $('#nameGroup').addClass 'has-error'
		else
			$('#nameGroup').removeClass 'has-error'
		if !$('#emailField').val()
			return $('#emailGroup').addClass 'has-error'
		else
			$('#emailGroup').removeClass 'has-error'

		$('#popup').removeClass 'shown'
		console.log 'popup shown'
		handler.open(
			name: "PilotDC"
			description: generateDescription()
			amount: total*100
			email: $('#emailField').val()
		);

	$('#right-button').click (event) ->
		# Validation
		if !(toggled.ladies || toggled.unisex || toggled.hoodie)
			return alert "You need to pick at least one item!"
		if !$('#nameField').val()
			return $('#nameGroup').addClass 'has-error'
		else
			$('#nameGroup').removeClass 'has-error'
		if !$('#emailField').val()
			return $('#emailGroup').addClass 'has-error'
		else
			$('#emailGroup').removeClass 'has-error'

		$('#orderField').val generateSizes()
		$('#totalField').val total
		$('#js-submitForm').click()
		console.log 'clicked'
		return false;

	$('#js-closeForm').click (event) ->
		$('#popup').removeClass 'shown'
		return false

	$('.js-checkoutButton').click (event) ->
		console.log 'clicked'
		$('#popup').addClass 'shown'
		return false
