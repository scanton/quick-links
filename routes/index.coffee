models = require '../coffee_modules/models'
db = require '../coffee_modules/data-api'
express = require 'express'
router = express.Router()

hitLink = (linkData) ->
	console.log 'TODO: Record the actual HIT to the LINK'

router.get '/', (req, res) ->
	res.render 'index',
		title: 'Kweak - Quick Links'

router.get '/l/:hashId', (req, res) ->
	hashId = req.params.hashId
	if hashId
		db.getLinkByHash hashId, (linkData) ->
			if linkData
				hitLink linkData
				res.redirect 303, linkData.url
			else
				res.redirect 303, 'http://meanrazorback.com'
	else
		res.redirect 303, 'http://kweak.com'

module.exports = router