app = angular.module 'user-input-forms', []

app.directive 'addLink', ->
	restrict: 'E'
	templateUrl: '/partials/directives/add-link.html'
	controller: ($scope, $log) ->
		#$log.info 'yo'

app.directive 'addIdLink', ->
	restrict: 'E'
	templateUrl: '/partials/directives/add-id-link.html'
	controller: ($scope, $log) ->
		#$log.info 'yo'