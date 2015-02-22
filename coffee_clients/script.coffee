app = angular.module 'main', [
	'ngRoute'
	'ui.bootstrap'
	'config'
	'btford.socket-io'
]

app.factory 'socket', (socketFactory) ->
	socketFactory()

app.controller 'MainController', ($scope, $modal, socket, $log) ->
	id = new Fingerprint({ie_activex: true}).get()
	id3d = new Fingerprint({canvas: true}).get()
	
	socket.emit 'id:user',
		id: id
		id3d: id3d

	window.socket = socket
	$scope.registrationAvailable = registrationAvailable = true
	
	$scope.userAuthenticated = userAuthenticated = false
	loginAttempts = 0

	$scope.showLoginModal = showLoginModal = ->
		$modal.open
			templateUrl: '/partials/modals/user-login'
			scope: $scope
			controller: ($scope, $modalInstance, $log) ->
				$scope.login = (username, password) ->
					if username && password
						$scope.loginAttempts = ++loginAttempts
						authData = { username: username, password: password }
						socket.emit 'authenticate:user', authData
						$modalInstance.dismiss 'submit'
				$scope.cancel = ->
					$modalInstance.dismiss 'cancel'
				$scope.showRegisterModal = ->
					$modalInstance.dismiss 'cancel'
					showRegisterModal()

	$scope.showRegisterModal = showRegisterModal = ->
		if registrationAvailable
			$modal.open
				templateUrl: '/partials/modals/user-register'
				scope: $scope
				controller: ($scope, $modalInstance, $log) ->
					$scope.register = (data) ->
						if data && data.username && data.password
							socket.emit 'register:user', data
						$modalInstance.dismiss 'submit'
					$scope.cancel = ->
						$modalInstance.dismiss 'cancel'


	$scope.submitLink = (link) ->
		socket.emit 'create:link',
			url: link

	$scope.submitIdLink = (data) ->
		socket.emit 'create:id-link', data

	$scope.submitGeoLink = (data) ->
		socket.emit 'create:geo-link', data
		window.location.replace 'http://kloce.com'

	socket.on 'update:link-hit', (data) ->
		$log.info data

	socket.on 'authenticated:user', (data) ->
		if data
			$scope.userAuthenticated = true
			$scope.userData = data

	socket.on 'authenticate-failed:user', (data) ->
		$modal.open
			templateUrl: '/partials/modals/failed-login'
			scope: $scope
			controller: ($scope, $modalInstance, $log) ->
				$scope.loginAttempts = loginAttempts
				$scope.tryAgain = ->
					$modalInstance.dismiss 'cancel'
					showLoginModal()
				$scope.cancel = ->
					$modalInstance.dismiss 'cancel'
	
	socket.on 'register-failed:user', (data) ->
		$modal.open
			templateUrl: '/partials/modals/error-notice'
			scope: $scope
			controller: ($scope, $modalInstance, $log) ->
				$scope.cancel = ->
					$modalInstance.dismiss 'cancel'
	
	socket.on 'warn', (data) ->
		$log.warn data

	socket.on 'error', (data) ->
		$log.error data

	#--linkTrackerController is used twice below
	linkTrackerController = ($scope, $modalInstance, $log) ->
		$scope.cancel = ->
			$modalInstance.dismiss 'cancel'
	socket.on 'created-success:link', (data) ->
		$scope.linkData = data
		$modal.open
			templateUrl: '/partials/modals/live-link-tracker'
			scope: $scope
			controller: linkTrackerController
	socket.on 'created-success:id-link', (data) ->
		$scope.linkData = data
		$modal.open
			templateUrl: '/partials/modals/live-link-tracker'
			scope: $scope
			controller: linkTrackerController
	#--/linkTrackerController