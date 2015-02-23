(function() {
  var app;

  app = angular.module('navigation', []);

  app.directive('mainNav', function() {
    return {
      restrict: 'E',
      templateUrl: '/partials/directives/main-nav.html',
      controller: function($scope, $log) {}
    };
  });

}).call(this);
