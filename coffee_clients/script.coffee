socket = io()

app = angular.module 'main', [
	'ngRoute'
	'ui.bootstrap'
	'config'
	'btford.socket-io'
]

app.factory 'socket', (socketFactory) ->
	socketFactory()

app.controller 'MainController', ($scope, socket, $log) ->
	$log.info 'MainController initialized in /coffee_clients/script.coffee'

