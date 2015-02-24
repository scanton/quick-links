app = angular.module 'main', [
	'ngRoute'
	'ui.bootstrap'
	'config'
	'btford.socket-io'
	'navigation'
	'user-input-forms'
	'links'
]

app.factory 'socket', (socketFactory) ->
	socketFactory()

addHitDetails = (links, hits) ->
	if links && hits
		key = hits[0].hashId
		l = links.length
		while l--
			if links[l].hashId == key
				return links[l].hitDetails = hits

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
	$scope.userLinkData = []

	userLogout = ->
		socket.emit 'logout:user', {}
		$scope.userAuthenticated = userAuthenticated = false
		loginAttempts = 0

	$scope.submitLink = (link) ->
		socket.emit 'create:link',
			url: link

	$scope.submitIdLink = (data) ->
		socket.emit 'create:id-link', data

	$scope.submitGeoLink = (data) ->
		socket.emit 'create:geo-link', data
		window.location.replace 'http://kloce.com'

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

	$scope.showAddLinkModal = showAddLinkModal = ->
		$modal.open
			templateUrl: '/partials/modals/add-link'
			scope: $scope
			controller: ($scope, $modalInstance, $log) ->
				$scope.cancel = ->
					$modalInstance.dismiss 'cancel'

	$scope.showAddIdLinkModal = showAddIdLinkModal = ->
		$modal.open
			templateUrl: '/partials/modals/add-id-link'
			scope: $scope
			controller: ($scope, $modalInstance, $log) ->
				$scope.cancel = ->
					$modalInstance.dismiss 'cancel'

	$scope.getHitDetails = (hits) ->
		socket.emit 'get:linkHitDetail', hits

	$scope.logout = ->
		userLogout()

	socket.on 'update:link-hit', (data) ->
		$log.info data

	socket.on 'authenticate:user:success', (data) ->
		if data
			$scope.userAuthenticated = true
			$scope.userData = data

	socket.on 'authenticate:user:fail', (data) ->
		userLogout()
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
	
	socket.on 'register:user:error', (data) ->
		$modal.open
			templateUrl: '/partials/modals/error-notice'
			scope: $scope
			controller: ($scope, $modalInstance, $log) ->
				$scope.cancel = ->
					$modalInstance.dismiss 'cancel'
	
	socket.on 'get:userLinkData:result', (data) ->
		$scope.userLinkData = data
		if data.hits
			socket.emit 'get:linkHitDetail', data.hits

	socket.on 'get:linkHitDetail:result', (hits) ->
		console.log hits
		addHitDetails $scope.userLinkData, hits

	socket.on 'warn', (data) ->
		$log.warn data

	socket.on 'error', (data) ->
		$log.error data

	#--linkTrackerController is used twice below
	linkTrackerController = ($scope, $modalInstance, $log) ->
		$scope.cancel = ->
			$modalInstance.dismiss 'cancel'
	socket.on 'create:link:success', (data) ->
		$scope.userLinkData.push data
		$scope.linkData = data
		$modal.open
			templateUrl: '/partials/modals/live-link-tracker'
			scope: $scope
			controller: linkTrackerController
	socket.on 'create:id-link:success', (data) ->
		$scope.userLinkData.push data
		$scope.linkData = data
		$modal.open
			templateUrl: '/partials/modals/live-link-tracker'
			scope: $scope
			controller: linkTrackerController
	#--/linkTrackerController