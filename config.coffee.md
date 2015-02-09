#Sunshine Configuration

	module.exports =

#Environment specific configurations

##Development

		development:
			name: 'development'
			port: process.env.PORT || 8080
			mongoPort: 27017
			mongoDatabaseName: 'kweak'
			mongoUser: ''
			mongoPassword: ''

##Staging

		staging:
			name: 'staging'
			port: 8080
			mongoPort: 27017
			mongoDatabaseName: 'kweak'
			mongoUser: ''
			mongoPassword: ''

##Production

		production:
			name: 'production'
			port: 80
			mongoPort: 27017
			mongoDatabaseName: 'kweak'
			mongoUser: ''
			mongoPassword: ''
