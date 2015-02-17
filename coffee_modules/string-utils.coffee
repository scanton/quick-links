
String::hashCode = ->
	hash = 0
	if @length == 0
		return hash
	i = 0
	while i < @length
		char = @charCodeAt(i)
		hash = (hash << 5) - hash + char
		hash = hash & hash
		# Convert to 32bit integer
		i++
	hash