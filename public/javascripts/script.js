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
    $scope.submitLink = function(link) {
      return socket.emit('create:link', {
        url: link
      });
    };
    $scope.submitIdLink = function(data) {
      return socket.emit('create:idLink', data);
    };
    socket.on('created-success:link', function(data) {
      return $log.info(data);
    });
    socket.on('created-success:idLink', function(data) {
      return $log.info(data);
    });
    socket.on('warn', function(data) {
      return $log.warn(data);
    });
    return socket.on('error', function(data) {
      return $log.error(data);
    });
  });

}).call(this);
