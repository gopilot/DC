#= require "_helper"

# requirejs makes life a lot easier when dealing with more than one
# javascript file and any sort of dependencies, and loads faster.

# for more info on require config, see http://requirejs.org/docs/api.html#config
require.config(
	paths:
		jquery: 'jquery'
)

require ['jquery'], ($) ->
	#console.log 'scripts loaded (via assets/js/main.coffee)'
	price =
		ladies: 15
		unisex: 15
		hoodie: 20

	total = 0

	toggled = 
		ladies: false
		unisex: false
		hoodie: false
		button: false

	generateDescription = () ->
		cart = []
		if toggled.ladies
			cart.push "Ladies' T-Shirt"
		if toggled.hoodie
			cart.push "Unisex Hoodie"
		if toggled.unisex
			cart.push "Unisex T-Shirt"
		return cart.join ", "

	handler = StripeCheckout.configure(
		key: "pk_test_bVNI8WnLVJlwNySLMliWPRjW"
		image: "/img/logo_square.png"
		token: (token, args) ->
			console.log("stripe 1", token)
			$.post('//localhost:3000/', {
				stripeToken: token.id
				ladies: toggled.ladies.toString()
				unisex: toggled.unisex.toString()
				hoodie: toggled.hoodie.toString()
				total: total
				email: $('#emailField').val()
			}, (err, result) ->
				if result == 'success'
					$('#orderField').val generateDescription()
					$('#totalField').val total
					$('#paidField').val 'true'
					$('#stripeField').val token.id
					$('#js-submitForm').click();
				else
					console.error("Error!", err, result)
					alert("Error submitting payment: "+err+", "+result)
			)
	)

	new Fireform '#checkoutForm', 'http://fireform.org/list/152/DC_Shirts', {
		callback: (err, val) ->
			checkout = $('#js-checkoutButton')
			text = checkout.html()
			color = checkout.css 'background'
			checkout.html("<i class='fa fa-check'></i> Order Sent!");
			checkout.css('background', '#7fc028')
			$('#js-closeForm').click();
			setTimeout () ->
				checkout.html(text);
				checkout.css('background', color)
			, 3000
	}

	$('.item').click (event) ->
		$(this).toggleClass 'selected'
		$(this).children('.check').toggleClass 'visible'
		itemName = $(this).attr('id')
		if toggled[itemName]
			total -= price[itemName]
		else
			total += price[itemName]
		toggled[itemName] = !toggled[itemName]
		$('#price').html "$"+total.toFixed(2)
		return false

	$('#left-button').click (event) ->
		if !(toggled.ladies || toggled.unisex || toggled.hoodie)
			return alert("You need to pick at least one item!")
		handler.open(
			name: "PilotDC"
			description: generateDescription()
			amount: total*100
			email: $('#emailField').val()
		);

	$('#right-button').click (event) ->
		if !(toggled.ladies || toggled.unisex || toggled.hoodie)
			return alert("You need to pick at least one item!")
		$('#orderField').val generateDescription()
		$('#totalField').val total
		$('#js-submitForm').click()
		return false;


	$('#js-closeForm').click (event) ->
		if toggled['button']
			toggled['button'] = false
			$('#js-checkoutButton').toggleClass 'visible'
			$('#js-slideForm').toggleClass 'visible'
			return false
		return true

	$('#button-container').click (event) ->
		if !toggled['button']
			$('#js-checkoutButton').toggleClass 'visible'
			$('#js-slideForm').toggleClass 'visible'
			toggled['button'] = true
		return false
