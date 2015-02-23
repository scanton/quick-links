app = angular.module 'links', []

app.directive 'linksOverview', ->
	restrict: 'E'
	templateUrl: '/partials/directives/links-overview.html'
	controller: ($scope, $log) ->
		#$log.info 'links'