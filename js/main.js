(function() {

  require.config({
    paths: {
      jquery: 'jquery',
      scrollTo: 'scrollTo',
      localScroll: 'localScroll'
    }
  });

  require(['jquery', 'scrollTo', 'localScroll'], function($, scrollTo, localScroll) {
    $.localScroll();
    return $('.judge-profile').bind('touchstart', function() {
      return $(this).toggleClass('hover');
    });
  });

}).call(this);
