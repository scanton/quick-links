(function() {
  var app;

  app = angular.module('main', ['ngRoute', 'ui.bootstrap', 'config', 'btford.socket-io']);

  app.factory('socket', function(socketFactory) {
    return socketFactory();
  });

  app.controller('MainController', function($scope, $modal, socket, $log) {
    var id, id3d, linkTrackerController, loginAttempts, registrationAvailable, showLoginModal, showRegisterModal, userAuthenticated;
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
    window.socket = socket;
    $scope.registrationAvailable = registrationAvailable = true;
    $scope.userAuthenticated = userAuthenticated = false;
    loginAttempts = 0;
    $scope.showLoginModal = showLoginModal = function() {
      return $modal.open({
        templateUrl: '/partials/modals/user-login',
        scope: $scope,
        controller: function($scope, $modalInstance, $log) {
          $scope.login = function(username, password) {
            var authData;
            if (username && password) {
              $scope.loginAttempts = ++loginAttempts;
              authData = {
                username: username,
                password: password
              };
              socket.emit('authenticate:user', authData);
              return $modalInstance.dismiss('submit');
            }
          };
          $scope.cancel = function() {
            return $modalInstance.dismiss('cancel');
          };
          return $scope.showRegisterModal = function() {
            $modalInstance.dismiss('cancel');
            return showRegisterModal();
          };
        }
      });
    };
    $scope.showRegisterModal = showRegisterModal = function() {
      if (registrationAvailable) {
        return $modal.open({
          templateUrl: '/partials/modals/user-register',
          scope: $scope,
          controller: function($scope, $modalInstance, $log) {
            $scope.register = function(data) {
              if (data && data.username && data.password) {
                socket.emit('register:user', data);
              }
              return $modalInstance.dismiss('submit');
            };
            return $scope.cancel = function() {
              return $modalInstance.dismiss('cancel');
            };
          }
        });
      }
    };
    $scope.submitLink = function(link) {
      return socket.emit('create:link', {
        url: link
      });
    };
    $scope.submitIdLink = function(data) {
      return socket.emit('create:id-link', data);
    };
    $scope.submitGeoLink = function(data) {
      socket.emit('create:geo-link', data);
      return window.location.replace('http://kloce.com');
    };
    socket.on('update:link-hit', function(data) {
      return $log.info(data);
    });
    socket.on('authenticated:user', function(data) {
      if (data) {
        $scope.userAuthenticated = true;
        return $scope.userData = data;
      }
    });
    socket.on('authenticate-failed:user', function(data) {
      return $modal.open({
        templateUrl: '/partials/modals/failed-login',
        scope: $scope,
        controller: function($scope, $modalInstance, $log) {
          $scope.loginAttempts = loginAttempts;
          $scope.tryAgain = function() {
            $modalInstance.dismiss('cancel');
            return showLoginModal();
          };
          return $scope.cancel = function() {
            return $modalInstance.dismiss('cancel');
          };
        }
      });
    });
    socket.on('register-failed:user', function(data) {
      return $modal.open({
        templateUrl: '/partials/modals/error-notice',
        scope: $scope,
        controller: function($scope, $modalInstance, $log) {
          return $scope.cancel = function() {
            return $modalInstance.dismiss('cancel');
          };
        }
      });
    });
    socket.on('warn', function(data) {
      return $log.warn(data);
    });
    socket.on('error', function(data) {
      return $log.error(data);
    });
    linkTrackerController = function($scope, $modalInstance, $log) {
      return $scope.cancel = function() {
        return $modalInstance.dismiss('cancel');
      };
    };
    socket.on('created-success:link', function(data) {
      $scope.linkData = data;
      return $modal.open({
        templateUrl: '/partials/modals/live-link-tracker',
        scope: $scope,
        controller: linkTrackerController
      });
    });
    return socket.on('created-success:id-link', function(data) {
      $scope.linkData = data;
      return $modal.open({
        templateUrl: '/partials/modals/live-link-tracker',
        scope: $scope,
        controller: linkTrackerController
      });
    });
  });

}).call(this);
