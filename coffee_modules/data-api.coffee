crypto = require 'crypto'
models = require '../coffee_modules/models.coffee'
salt = '-- insert crypto salt here --'

encrypt = (str) ->
	crypto.createHash 'md5'
	.update str + salt
	.digest 'hex'

getAll = (model, query, callback, errorHandler) ->
	model.find(
		query
		(err, data) ->
			if err && errorHandler
				errorHandler err
			if callback
				callback data
	) if model
getOne = (model, query, callback, errorHandler) ->
	model.findOne(
		query
		(err, data) ->
			if err && errorHandler
				errorHandler err
			if callback
				callback data
	) if model
upsert = (model, query, data, callback, errorHandler) ->
	model.findOneAndUpdate(
		query
		{ $set: data }
		{ upsert: true }
		(err, rows) ->
			if err && errorHandler
				errorHandler err
			if callback
				callback rows
	) if model

module.exports = 

	registerUser: (regData, callback) ->
		if regData && regData.password
			regData.password = encrypt regData.password
			upsert models.User, { username: regData.username, password: regData.password }, regData, callback
	
	authenticateUser: (username, password, callback) ->
		if username && password
			getOne models.User, { username: username, password: encrypt(password) }, (result) ->
				callback result if callback
	
	addHitToLink: (hitId, linkId, callback) ->
		models.Link.findByIdAndUpdate(
			linkId
			{ $push: { 'hits': hitId } }
			{}
			(err, result) ->
				callback result if callback
		)
	
	isLinkHashUnique: (hash, callback) ->
		models.Link.findOne {hash: hash}, (err, rows) ->
			console.error err if err
			callback !rows

	insertIdentity: (data, callback) ->
		if data && (data.firstName || data.lastName || data.email)
			models.Identity.create data, (err, result) ->
				console.error err if err
				callback result if callback

	getUserLinks: (userId, callback, errorHandler) ->
		if userId
			getAll models.Link, {creator: userId}, (rows) ->
				callback rows if callback
			, errorHandler

	getLinkHitDetail: (hitIds, callback, errorHandler) ->
		if hitIds
			models.Hit.find { '_id': { $in: hitIds } }, (err, rows) ->
				callback rows if callback
			, errorHandler

	getLinkByHash: (hashId, callback) ->
		if hashId
			getOne models.Link, {hashId: hashId}, (result) ->
				callback result if callback

	getIpDetail: (ip, callback) ->
		if ip
			getOne models.IpDetail, {ip: ip}, (result) ->
				callback result if callback

	insertIpDetail: (data, callback) ->
		if data
			models.IpDetail.create data, (err, result) ->
				console.error err if err
				callback result if callback

	insertLink: (data, callback) ->
		if data && data.url && data.hashId
			models.Link.create data, (err, result) ->
				console.error err if err
				callback result if callback

	insertHit: (data, callback) ->
		if data
			models.Hit.create data, (err, result) ->
				console.error err if err
				callback result

