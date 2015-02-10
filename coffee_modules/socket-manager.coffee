_und = require 'underscore'
models = require '../coffee_modules/models'
db = require '../coffee_modules/data-api'
socketInfo = {}

module.exports = (io) ->

	io.on 'connection', (socket) ->
		socketInfo['_' + socket.id] = {} if ! socketInfo['_' + socket.id]
		info = socketInfo['_' + socket.id]

		info.domain = socket.handshake.headers.host.split(':')[0]
		info.ip = socket.client.conn.remoteAddress
		info.socketId = socket.id

		console.log '+ user ' + socket.id + ' connected + domain: ' + info.domain + ' IP: ' + info.ip

		socket.on 'id:user', (data) ->
			info.sig = data.id
			info.sig3d = data.id3d
			console.log '****** id:user ******'
			console.log info
			console.log '****** ******* ******'

		socket.on 'create:link', (data) ->
			if data.link
				console.log '***** create:link *****'
				console.log data
				console.log '****** ******* ******'