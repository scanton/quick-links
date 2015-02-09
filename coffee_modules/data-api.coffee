models = require '../coffee_modules/models.coffee'
getAll = (model, query, callback) ->
	if model
		model.find(
			query
			(err, data) ->
				console.log err if err
				callback data if callback
		)
getOne = (model, query, callback) ->
	if model
		model.findOne(
			query
			(err, data) ->
				console.log err if err
				callback data if callback
		)
upsert = (model, query, data, callback) ->
	if model && data
		model.findOneAndUpdate(
			query
			{$set: data}
			{upsert: true}
			(err, rows) ->
				console.log err if err
				callback rows if callback
		)

module.exports = {} #export your database API here
