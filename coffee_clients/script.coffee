app = angular.module 'main', [
	'ngRoute'
	'ui.bootstrap'
	'config'
	'btford.socket-io'
]

app.factory 'socket', (socketFactory) ->
	socketFactory()

app.controller 'MainController', ($scope, socket, $log) ->
	id = new Fingerprint({ie_activex: true}).get()
	id3d = new Fingerprint({canvas: true}).get()
	
	socket.emit 'id:user',
		id: id
		id3d: id3d

	$scope.submitLink = (link) ->
		socket.emit 'create:link',
			url: link

	$scope.submitIdLink = (data) ->
		socket.emit 'create:idLink', data

	socket.on 'created-success:link', (data) ->
		$log.info data

	socket.on 'created-success:idLink', (data) ->
		$log.info data

	socket.on 'warn', (data) ->
		$log.warn data

	socket.on 'error', (data) ->
		$log.error data