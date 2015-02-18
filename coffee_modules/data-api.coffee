models = require '../coffee_modules/models.coffee'

getAll = (model, query, callback) ->
	model.find(
		query
		(err, data) ->
			console.error err if err
			callback data if callback
	) if model
getOne = (model, query, callback) ->
	model.findOne(
		query
		(err, data) ->
			console.error err if err
			callback data if callback
	) if model
upsert = (model, query, data, callback) ->
	model.findOneAndUpdate(
		query
		{$set: data}
		{upsert: true}
		(err, rows) ->
			console.log err if err
			callback rows if callback
	) if model

module.exports = 
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

	upsertIdentity: (data, callback) ->
		if data && (data.firstName || data.lastName || data.email)
			models.Identity.create data, (err, result) ->
				console.error err if err
				callback result

	getLinkByHash: (hashId, callback) ->
		if hashId
			getOne models.Link, {hashId: hashId}, (result) ->
				callback result

	upsertLink: (data, callback) ->
		if data && data.url && data.hashId
			upsert models.Link, {hashId: data.hashId}, data, callback

	insertHit: (data, callback) ->
		if data
			models.Hit.create data, (err, result) ->
				console.error err if err
				callback result

