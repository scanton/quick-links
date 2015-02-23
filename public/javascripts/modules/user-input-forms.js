(function() {
  var app;

  app = angular.module('user-input-forms', []);

  app.directive('addLink', function() {
    return {
      restrict: 'E',
      templateUrl: '/partials/directives/add-link.html',
      controller: function($scope, $log) {}
    };
  });

  app.directive('addIdLink', function() {
    return {
      restrict: 'E',
      templateUrl: '/partials/directives/add-id-link.html',
      controller: function($scope, $log) {}
    };
  });

}).call(this);
