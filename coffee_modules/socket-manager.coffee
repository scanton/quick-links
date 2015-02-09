_und = require 'underscore'
models = require '../coffee_modules/models'
db = require '../coffee_modules/data-api'

module.exports = (io) ->

	io.on 'connection', (socket) ->
		domain = socket.handshake.headers.host.split(':')[0]
		ip = socket.client.conn.remoteAddress
		console.log '+ user ' + socket.id + ' connected + domain: ' + domain + ' IP: ' + ip
