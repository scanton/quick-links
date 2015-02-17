models = require '../coffee_modules/models.coffee'

getAll = (model, query, callback) ->
	model.find(
		query
		(err, data) ->
			console.log err if err
			callback data if callback
	) if model
getOne = (model, query, callback) ->
	model.findOne(
		query
		(err, data) ->
			console.log err if err
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
	isLinkHashUnique: (hash, callback) ->
		models.Link.findOne {hash: hash}, (err, rows) ->
			console.log err if err
			callback !rows

	upsertIdentity: (data, callback) ->
		if data && (data.firstName || data.lastName || data.email)
			models.Identity.create data, (err, result) ->
				console.log err if err
				callback result

	upsertLink: (data, callback) ->
		if data && data.url && data.hashId
			upsert models.Link, {hashId: data.hashId}, data, callback
