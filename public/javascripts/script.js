(function() {
  var addHitDetails, app;

  app = angular.module('main', ['ngRoute', 'ui.bootstrap', 'config', 'btford.socket-io', 'navigation', 'user-input-forms', 'links']);

  app.factory('socket', function(socketFactory) {
    return socketFactory();
  });

  addHitDetails = function(links, hits) {
    var key, l;
    if (links && hits) {
      key = hits[0].hashId;
      l = links.length;
      while (l--) {
        if (links[l].hashId === key) {
          return links[l].hitDetails = hits;
        }
      }
    }
  };

  app.controller('MainController', function($scope, $modal, socket, $log) {
    var id, id3d, linkTrackerController, loginAttempts, registrationAvailable, showAddIdLinkModal, showAddLinkModal, showLoginModal, showRegisterModal, userAuthenticated, userLogout;
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
    $scope.userLinkData = [];
    userLogout = function() {
      socket.emit('logout:user', {});
      $scope.userAuthenticated = userAuthenticated = false;
      return loginAttempts = 0;
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
    $scope.showAddLinkModal = showAddLinkModal = function() {
      return $modal.open({
        templateUrl: '/partials/modals/add-link',
        scope: $scope,
        controller: function($scope, $modalInstance, $log) {
          return $scope.cancel = function() {
            return $modalInstance.dismiss('cancel');
          };
        }
      });
    };
    $scope.showAddIdLinkModal = showAddIdLinkModal = function() {
      return $modal.open({
        templateUrl: '/partials/modals/add-id-link',
        scope: $scope,
        controller: function($scope, $modalInstance, $log) {
          return $scope.cancel = function() {
            return $modalInstance.dismiss('cancel');
          };
        }
      });
    };
    $scope.getHitDetails = function(hits) {
      return socket.emit('get:linkHitDetail', hits);
    };
    $scope.logout = function() {
      return userLogout();
    };
    socket.on('update:link-hit', function(data) {
      return $log.info(data);
    });
    socket.on('authenticate:user:success', function(data) {
      if (data) {
        $scope.userAuthenticated = true;
        return $scope.userData = data;
      }
    });
    socket.on('authenticate:user:fail', function(data) {
      userLogout();
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
    socket.on('register:user:error', function(data) {
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
    socket.on('get:userLinkData:result', function(data) {
      $scope.userLinkData = data;
      if (data.hits) {
        return socket.emit('get:linkHitDetail', data.hits);
      }
    });
    socket.on('get:linkHitDetail:result', function(hits) {
      console.log(hits);
      return addHitDetails($scope.userLinkData, hits);
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
    socket.on('create:link:success', function(data) {
      $scope.userLinkData.push(data);
      $scope.linkData = data;
      return $modal.open({
        templateUrl: '/partials/modals/live-link-tracker',
        scope: $scope,
        controller: linkTrackerController
      });
    });
    return socket.on('create:id-link:success', function(data) {
      $scope.userLinkData.push(data);
      $scope.linkData = data;
      return $modal.open({
        templateUrl: '/partials/modals/live-link-tracker',
        scope: $scope,
        controller: linkTrackerController
      });
    });
  });

}).call(this);
