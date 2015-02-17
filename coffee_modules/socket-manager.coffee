_und = require 'underscore'
models = require '../coffee_modules/models'
db = require '../coffee_modules/data-api'
Hashids = require 'hashids'
hasher = new Hashids 'kweak-hashid-salt'

socketInfo = {}

getUniqueHash = (callback) ->
	seed = Math.floor(Math.random() * 1000)
	time = Date.now() * 1000
	hash = hasher.encode time + seed
	db.isLinkHashUnique hash, (isUnique) ->
		if isUnique
			callback hash
		else
			getUniqueHash callback

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
			if data.url
				getUniqueHash (hashId) ->
					if hashId
						data.hashId = hashId
						db.upsertLink data, (rows) ->
							socket.emit 'created-success:link', rows
			else
				socket.emit 'error', 'create:link error'

		socket.on 'create:idLink', (data) ->
			if data
				getUniqueHash (hashId) ->
					if hashId
						db.upsertIdentity data, (result) ->
							db.upsertLink {url: data.url, hashId: hashId, intendedRecepient: result._id}, (rows) ->
								socket.emit 'created-success:idLink', rows
					else
						socket.emit 'error', 'create:idLink error - no hashId'
			else
				socket.emit 'error', 'create:idLink error - no data'
