#= require "_helper"

# requirejs makes life a lot easier when dealing with more than one
# javascript file and any sort of dependencies, and loads faster.

# for more info on require config, see http://requirejs.org/docs/api.html#config
require.config
    paths:
        jquery: 'jquery'
        scrollTo: 'scrollTo'
        localScroll: 'localScroll'

require ['jquery', 'scrollTo', 'localScroll'], ($, scrollTo, localScroll) ->
    #console.log 'scripts loaded (via assets/js/main.coffee)'
    $.localScroll()

