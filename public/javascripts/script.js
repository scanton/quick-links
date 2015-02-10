(function() {
  var app;

  app = angular.module('main', ['ngRoute', 'ui.bootstrap', 'config', 'btford.socket-io']);

  app.factory('socket', function(socketFactory) {
    return socketFactory();
  });

  app.controller('MainController', function($scope, socket, $log) {
    var id, id3d;
    id = new Fingerprint({
      ie_activex: true
    }).get();
    id3d = new Fingerprint({
      canvas: true
    }).get();
    socket.emit('id:user', {
      id: id,
      id3d: id3d
    });
    return $log.info('MainController initialized in /coffee_clients/script.coffee');
  });

}).call(this);
