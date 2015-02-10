#socket = io()

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
	$log.info 'MainController initialized in /coffee_clients/script.coffee'

