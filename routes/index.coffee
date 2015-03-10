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
	db.insertHit hitData, (hitData) ->
		if hitData
			db.addHitToLink hitData._id, linkId, (linkData) ->
				callback { hit: hitData, link: linkData } if callback

module.exports = (socketManager) ->

	router.get '/', (req, res) ->
		res.render 'index',
			title: 'Kweak - Quick Links'

	router.get '/key/:hashId', (req, res) ->
		res.cookie 'referer', req.headers['referer']
		res.render 'forward',
			title: 'Kweak - Secure Links'
			hashId: req.params.hashId
			head: req.headers
			
	router.get '/unlock/:hashId/key/:sig/sum/:sig3d', (req, res) ->
		hashId = req.params.hashId
		sig = req.params.sig
		sig3d = req.params.sig3d
		req.headers.referer = req.cookies.referer
		if hashId
			db.getLinkByHash hashId, (linkData) ->
				if linkData
					hitLink req, linkData._id, (hitResult) ->
						socketManager.emitLinkHit hitResult
					res.redirect 303, linkData.url
				else
					res.redirect 303, 'http://meanrazorback.com'
		else
			res.redirect 303, 'http://kweak.com'
	router