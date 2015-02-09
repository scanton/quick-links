(function() {
  var app;

  app = angular.module('config', []);

  app.config(function($routeProvider, $locationProvider) {
    var path;
    path = $routeProvider.when;
    return "path '/',\n	templateUrl: '/partials/home.html'\n	controller: 'HomeController'";
  });

}).call(this);
