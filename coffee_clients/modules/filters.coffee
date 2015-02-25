app = angular.module 'filters', []

app.factory 'langDict', ->
	'en': 'English'
	'en-us': 'English (US)'
	'en-uk': 'English (UK)'
	'de': 'German'
	'de-de': 'German (Germany)'

app.filter 'headerLanguages', (langDict) ->
	replaceLangs = (langArray) ->
		a = []
		l = langArray.length
		while l--
			key = langArray[l].toLowerCase()
			if langDict[key]
				a.unshift langDict[key]
			else
				a.unshift langArray[l]
		a
	(langs) ->
		if langs
			a = langs.split ';'
			a = a[0].split ','
			replaceLangs a