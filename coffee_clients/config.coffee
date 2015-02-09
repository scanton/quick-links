app = angular.module 'config', []

app.config ($routeProvider, $locationProvider) ->
	#$locationProvider.html5Mode true
	path = $routeProvider.when
	"""
	path '/',
		templateUrl: '/partials/home.html'
		controller: 'HomeController'
	"""