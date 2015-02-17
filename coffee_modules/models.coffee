mongoose = require 'mongoose'
Schema = mongoose.Schema
MongoId = Schema.Types.ObjectId

module.exports = 
	Hit: mongoose.model('Hit',
		hashId: String
		created: { type: Date, default: Date.now }
	)
	Identity: mongoose.model('Identity',
		firstName: String
		lastName: String
		email: String
		sig: String
		sig3d: String
		ip: String
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
	PageView: mongoose.model('PageView',
		url: String
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