mongoose = require 'mongoose'
Schema = mongoose.Schema
MongoId = Schema.Types.ObjectId

module.exports = 
	Hit: mongoose.model('Hit',
		baseUrl: String
		body: Object
		cookies: Object
		hashId: String #-should match the Link hashId
		headers: Object
		hostname: String
		ip: String
		ips: Array
		originalUrl: String
		params: Object
		path: String
		protocol: String
		query: Object
		route: Object
		secure: Boolean
		session: Object
		sig: String #-must get from client
		sig3d: String #-must get from client
		signedCookies: Object
		subdomains: Array
		xhr: Boolean
		created: { type: Date, default: Date.now }
	)
	Identity: mongoose.model('Identity',
		firstName: {type:String , trim: true }
		lastName: {type:String , trim: true }
		email: {type:String , trim: true }
		sig: String
		sig3d: String
		ip: String
		modified: { type: Date, default: Date.now }
		created: { type: Date, default: Date.now }
	)
	IpDetail: mongoose.model('IpDetail',
		ipAddress: { type: String, unique: true, required: true }
		addressType: String
		isp: String
		timezone: String
		country: String
		stateRegion: String
		city: String
		coordinates: Array
		modified: { type: Date, default: Date.now }
		created: { type: Date, default: Date.now }
	)
	Link: mongoose.model('Link',
		url: String
		hashId: { type: String, unique: true }
		creator: { type: MongoId, ref: 'User' }
		hits: [
			type: MongoId
			ref: 'Hit'
		]
		intendedRecepient: { type: MongoId, ref: 'Identity' }
		isActive: { type: Boolean, default: 1 }
		created: { type: Date, default: Date.now }
	)
	User: mongoose.model('User',
		firstName: String
		lastName: String
		username: { type: String, unique: true }
		password: String
		isActive: { type: Boolean, default: 1 }
		created: { type: Date, default: Date.now }
	)