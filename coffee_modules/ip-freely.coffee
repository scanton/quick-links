"""
  This module is used to get detailed IP data
"""

request = require 'request'
cheerio = require 'cheerio'

getUrl = (url, callback, errorHandler) ->
	request url, (error, response, html) ->
		if !error && response.statusCode == 200
			$ = cheerio.load html
			callback $ if callback
		else
			console.error '** ERROR from ip-freely **', error
			errorHandler error, response, html if errorHandler

capFirstLetter = (str) ->
	str.charAt(0).toUpperCase() + str.slice(1)

clenup = (str) ->
	a = str.toLowerCase().split('/').join('').split('  ').join(' ').split(' ')
	l = a.length
	while l-- > 1
		a[l] = capFirstLetter a[l]
	a.join ''

module.exports =
	getIpData: (ip, callback, errorHandler) ->
		getUrl 'https://db-ip.com/' + ip, ($) ->
			$table = $ '.table-striped'
			$rows = $table.find 'tr'
			result = {}
			$rows.each ->
				$this = $ this
				heading = $this.find('th').text()
				value = $this.find('td').text()
				h = clenup heading
				if h == 'coordinates'
					value = value.split ', '
				result[h] = value
			callback result
		, errorHandler