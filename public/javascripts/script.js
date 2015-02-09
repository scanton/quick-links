(function() {
  var app, socket;

  socket = io();

  app = angular.module('main', ['ngRoute', 'ui.bootstrap', 'config', 'btford.socket-io']);

  app.factory('socket', function(socketFactory) {
    return socketFactory();
  });

  app.controller('MainController', function($scope, socket, $log) {
    return $log.info('MainController initialized in /coffee_clients/script.coffee');
  });

}).call(this);
