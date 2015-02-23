(function() {
  var app;

  app = angular.module('links', []);

  app.directive('linksOverview', function() {
    return {
      restrict: 'E',
      templateUrl: '/partials/directives/links-overview.html',
      controller: function($scope, $log) {}
    };
  });

}).call(this);
