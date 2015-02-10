express = require 'express'
router = express.Router()

router.get '/', (req, res) ->
	res.render 'index',
		title: 'Kweak - Quick Links'
		description: 'Track ROI of all your internet assets'

module.exports = router