app = angular.module 'navigation', []

app.directive 'mainNav', ->
	restrict: 'E'
	templateUrl: '/partials/directives/main-nav.html'
	controller: ($scope, $log) ->
		#$log.info 'main-nav loaded from /coffee_clients/modules/main-nav.coffee'