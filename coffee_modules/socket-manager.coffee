_und = require 'underscore'
models = require '../coffee_modules/models'
db = require '../coffee_modules/data-api'
Hashids = require 'hashids'
hasher = new Hashids 'kweak-hashid-salt'
ipFreely = require '../coffee_modules/ip-freely'

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

		socket.on 'register:user', (regData) ->
			if regData && regData.firstName && regData.lastName && regData.username && regData.password
				db.registerUser regData, (userData) ->
					if userData
						socket.emit 'register-success:user', userData
						info.authenticated = true
						info.userData = userData
						socket.emit 'authenticated:user', userData
					else
						socket.emit 'register-failed:user', 'registration error'

		socket.on 'authenticate:user', (authData) ->
			if authData && authData.username && authData.password
				db.authenticateUser authData.username, authData.password, (userData) ->
					if userData
						info.authenticated = true
						info.userData = userData
						socket.emit 'authenticated:user', userData
					else
						info.authenticated = info.userData = false;
						socket.emit 'authenticate-failed:user', 'invalid user credentials'

		socket.on 'get:ip-detail', (ip) ->
			if ip
				db.getIpDetail ip, (data) ->
					if data
						data.ip = ip
						console.log ' pulling from cache ' + ip
						socket.emit 'result:ip-detail', data
					else
						console.log ' crawling for : ' + ip
						ipFreely.getIpData ip, (data) ->
							if data
								data.ip = ip
								socket.emit 'result:ip-detail', data
								db.upsertIpDetail data

		socket.on 'create:link', (data) ->
			if data.url
				getUniqueHash (hashId) ->
					if hashId
						data.hashId = hashId
						db.upsertLink data, (rows) ->
							socket.emit 'created-success:link', rows
			else
				socket.emit 'error', 'create:link error'

		socket.on 'create:id-link', (data) ->
			if data
				getUniqueHash (hashId) ->
					if hashId
						db.upsertIdentity data, (result) ->
							db.upsertLink {url: data.url, hashId: hashId, intendedRecepient: result._id}, (rows) ->
								socket.emit 'created-success:id-link', rows
					else
						socket.emit 'error', 'create:id-link error - no hashId'
			else
				socket.emit 'error', 'create:id-link error - no data'

	emitLinkHit: (data) ->
		io.to link.hashId #room
			.emit 'update:link-hit', data