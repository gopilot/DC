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


	paymentsServer = "http://payments.gopilot.org"
	

	price =
		ladies: 15
		unisex: 15
		hoodie: 30

	total = 0

	toggled = 
		ladies: false
		unisex: false
		hoodie: false

	generateOrder = () ->
		cart = []
		if toggled.ladies
			cart.push $('#ladies').prev().val()+" Ladies' T-Shirt"
		if toggled.hoodie
			cart.push $('#hoodie').prev().val()+" Hoodie"
		if toggled.unisex
			cart.push $('#unisex').prev().val()+" Unisex T-Shirt"
		return cart.join ", "

	
	finished = (val, err) ->
		console.log 'Order placed!'
		checkout = $('#js-orderButton')
		$('.item').removeClass 'selected'
		$('select').removeClass 'visible'
		text = checkout.html()
		color = checkout.css 'background'
		checkout.html("<span class='finished-text'><i class='fa fa-check'></i> Order Sent!</span>");
		checkout.css('background', '#7fc028')
		setTimeout () ->
			checkout.html(text);
			checkout.css('background', color)
			$('#popup').removeClass 'shown'
		, 2000

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
				livePayments: "false"
				email: $('#emailField').val()
				first_name: $('#nameField').val().split(" ")[0]
				last_name: $('#nameField').val().split(" ")[1]
				order: generateOrder(),
				event: 'DC'
			}, finished)
	)
	
	$('.item').click (event) ->
		$(this).toggleClass 'selected'
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

		handler.open(
			name: "PilotDC"
			description: generateOrder()
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
		$.post(paymentsServer, {
			ladies: toggled.ladies.toString()
			unisex: toggled.unisex.toString()
			hoodie: toggled.hoodie.toString()
			total: total
			livePayments: "false"
			email: $('#emailField').val()
			first_name: $('#nameField').val().split(" ")[0]
			last_name: $('#nameField').val().split(" ")[1]
			order: generateOrder()
			event: 'DC'
		}, finished)
		return false;

	$('#js-closeForm').click (event) ->
		$('#popup').removeClass 'shown'
		return false

	$('.js-checkoutButton').click (event) ->
		console.log 'clicked'
		$('#popup').addClass 'shown'
		return false
