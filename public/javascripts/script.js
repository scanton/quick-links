(function() {
  var addHitDetails, app;

  app = angular.module('main', ['ngRoute', 'ui.bootstrap', 'config', 'btford.socket-io', 'angularMoment', 'navigation', 'filters', 'user-input-forms', 'links']);

  app.factory('socket', function(socketFactory) {
    return socketFactory();
  });

  app.factory('ipDictionary', function() {
    var details;
    details = {};
    return {
      set: function(ip, data) {
        return details[ip] = data;
      },
      get: function(ip) {
        return details[ip];
      },
      details: details
    };
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

  app.controller('MainController', function($scope, $modal, socket, ipDictionary, $log) {
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
    $scope.ipUpdates = 0;
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
      return socket.emit('get:link-hit-detail', hits);
    };
    $scope.logout = function() {
      return userLogout();
    };
    socket.on('update:link-hit', function(data) {
      var l, ld, _results;
      l = $scope.userLinkData.length;
      _results = [];
      while (l--) {
        ld = $scope.userLinkData[l];
        if (ld.hashId === data.link.hashId) {
          ld.hitDetails.push(data.hit);
          _results.push(ld.hits.push(data.hit._id));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
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
    socket.on('get:user-link-data:result', function(data) {
      $scope.userLinkData = data;
      if (data.hits) {
        return socket.emit('get:link-hit-detail', data.hits);
      }
    });
    socket.on('get:link-hit-detail:result', function(hits) {
      return addHitDetails($scope.userLinkData, hits);
    });
    socket.on('get:ip-detail:result', function(ipDetail) {
      if (ipDetail && ipDetail.ip) {
        ipDictionary.set(ipDetail.ip, ipDetail);
        return ++$scope.ipUpdates;
      }
    });
    socket.on('get:ip-detail-list:result', function(ipDetailList) {
      var ipDetail, l;
      if (ipDetailList) {
        l = ipDetailList.length;
        while (l--) {
          ipDetail = ipDetailList[l];
          if (ipDetail && ipDetail.ip) {
            ipDictionary.set(ipDetail.ip, ipDetail);
          }
        }
        return ++$scope.ipUpdates;
      }
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
