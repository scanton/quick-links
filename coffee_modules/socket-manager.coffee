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

fetchUserLinkData = (userData, callback) ->
	if userData && userData._id
		db.getUserLinks userData._id, (links) ->
			callback links if callback

joinRooms = (socket, list) ->
	if socket && list
		l = list.length
		while l--
			socket.join list[l].hashId

deDup = (arr) ->
	if arr
		dict = {}
		l = arr.length
		cleanArr = []
		while l--
			x = arr[l]
			if !dict[x]
				cleanArr.unshift x
				dict[x] = true
		cleanArr

getIpDetail = (ip, callback) ->
	if ip
		db.getIpDetail ip, (ipDetail) ->
			if ipDetail
				ipDetail.ip = ip
				callback ipDetail if callback
			else
				ipFreely.getIpData ip, (ipDetail) ->
					if ipDetail
						ipDetail.ip = ip
						db.insertIpDetail ipDetail
						callback ipDetail if callback
						

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
			getIpDetail info.ip, (detail) ->
				console.log '****** detail:ip ******'
				console.log detail
				console.log '****** ******* ******'


		socket.on 'register:user', (regData) ->
			if regData && regData.firstName && regData.lastName && regData.username && regData.password
				db.registerUser regData, (userData) ->
					if userData
						socket.emit 'register:user:success', userData
						info.authenticated = true
						info.userData = userData
						socket.emit 'authenticate:user:success', userData
						fetchUserLinkData userData, (links) ->
							joinRooms socket, links
							socket.emit 'get:user-link-data:result', links
					else
						socket.emit 'register:user:error', 'registration error'

		socket.on 'authenticate:user', (authData) ->
			if authData && authData.username && authData.password
				db.authenticateUser authData.username, authData.password, (userData) ->
					if userData
						info.authenticated = true
						info.userData = userData
						socket.emit 'authenticate:user:success', userData
						fetchUserLinkData userData, (links) ->
							joinRooms socket, links
							socket.emit 'get:user-link-data:result', links
					else
						info.authenticated = false
						socket.emit 'authenticate:user:fail', 'invalid user credentials'

		socket.on 'logout:user', ->
			info.authenticated = false
			i = info.userData
			socket.emit 'logout:user:success', i.firstName + ' ' + i.lastName + ' logged out'

		socket.on 'get:link-hit-detail', (arr) ->
			if arr
				db.getLinkHitDetail arr, (hits) ->
					if hits
						socket.emit 'get:link-hit-detail:result', hits
						a = []
						l = hits.length
						while l--
							ip = hits[l].ip
							a.push ip
						db.getIpDetailList deDup(a), (ipDetails) ->
							socket.emit 'get:ip-detail-list:result', ipDetails

		socket.on 'create:link', (data) ->
			if data.url
				getUniqueHash (hashId) ->
					if hashId
						data.hashId = hashId
						if info.authenticated && info.userData
							data.creator = info.userData._id
						db.insertLink data, (result) ->
							socket.emit 'create:link:success', result
			else
				socket.emit 'create:link:error', 'invalid url'
				socket.emit 'error', 'create:link error'

		socket.on 'create:id-link', (data) ->
			if data
				getUniqueHash (hashId) ->
					if hashId
						if info.authenticated && info.userData
							data.creator = info.userData._id
						db.insertIdentity data, (result) ->
							db.insertLink {url: data.url, hashId: hashId, intendedRecepient: result._id}, (rows) ->
								socket.emit 'create:id-link:success', rows
					else
						socket.emit 'create:id-link:error', 'invalid hashId'
						socket.emit 'error', 'create:id-link error - no hashId'
			else
				socket.emit 'create:id-link:error', 'invalid link data'
				socket.emit 'error', 'create:id-link error - no data'

		socket.on 'get:ip-detail', (ip) ->
			if ip
				db.getIpDetail ip, (data) ->
					if data
						data.ip = ip
						socket.emit 'get:ip-detail:result', data
					else
						ipFreely.getIpData ip, (data) ->
							if data
								data.ip = ip
								socket.emit 'get:ip-detail:result', data
								db.insertIpDetail data

	emitLinkHit: (data) ->
		if data && data.link && data.link.hashId && data.hit && data.hit.ip
			ip = data.hit.ip
			hashId = data.link.hashId
			io.to hashId #room
				.emit 'update:link-hit', data
			getIpDetail ip, (detail) ->
				console.log detail
				io.to hashId
					.emit 'get:ip-detail:result', detail

