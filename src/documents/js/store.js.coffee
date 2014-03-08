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

	handler = StripeCheckout.configure(
	  key: "pk_test_bVNI8WnLVJlwNySLMliWPRjW"
	  image: "/img/logo_square.png"
	  token: (token, args) ->
	  	console.log token
	  	console.log args
	)

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

	generateDescription = (cash) ->
		result = 'Item Name'
		result += ' (Pay at the door)' if cash
		return result

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
		handler.open(
		  name: "PilotDC"
		  description: generateDescription(false)
		  amount: total*100
		);

	$('#right-button').click (event) ->
		handler.open(
		  name: "PilotDC"
		  description: generateDescription(true)
		  amount: 0
		);

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
