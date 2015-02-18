models = require '../coffee_modules/models'
db = require '../coffee_modules/data-api'
express = require 'express'
router = express.Router()

hitLink = (req, linkId, callback) ->
	hitData =
		baseUrl: req.baseUrl
		body: req.body
		cookies: req.cookies
		hashId: req.params.hashId
		headers: req.headers
		hostname: req.hostname
		ip: req.ip
		ips: req.ips
		originalUrl: req.originalUrl
		params: req.params
		path: req.path
		protocol: req.protocol
		query: req.query
		route: req.route
		secure: req.secure
		session: req.session
		sig: req.params.sig
		sig3d: req.params.sig3d
		signedCookies: req.signedCookies
		subdomains: req.subdomains
		xhr: req.xhr
	db.insertHit hitData, (result) ->
		db.addHitToLink result._id, linkId
		callback result if callback

router.get '/', (req, res) ->
	res.render 'index',
		title: 'Kweak - Quick Links'

router.get '/key/:hashId', (req, res) ->
	res.render 'forward',
		title: 'Kweak - Secure Links'
		hashId: req.params.hashId

router.get '/unlock/:hashId/key/:sig/sum/:sig3d', (req, res) ->
	hashId = req.params.hashId
	sig = req.params.sig
	sig3d = req.params.sig3d
	if hashId
		db.getLinkByHash hashId, (linkData) ->
			if linkData
				hitLink req, linkData._id, (hitResult) ->
					console.log hitResult
				res.redirect 303, linkData.url
			else
				res.redirect 303, 'http://meanrazorback.com'
	else
		res.redirect 303, 'http://kweak.com'

module.exports = router