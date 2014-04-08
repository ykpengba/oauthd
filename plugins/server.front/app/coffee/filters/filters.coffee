define [], () ->
	registerFilters = (app) ->
		app.register.filter 'toUpper', ->
			return (input, scope) ->
				if input
					return input.toUpperCase()

		app.register.filter 'capitalize', ->
			return (input, scope) ->
				if input
					str = ''
					arr = input.split '_'
					for i in arr
						str += i.substring(0,1).toUpperCase() + i.substring(1) + ' '
					str = str.substring 0, str.length - 1
					return str

		app.register.filter 'trunc', ->
			return (input, chars) ->
				return input if isNaN(chars)
				return '' if chars <= 0
				if input && input.length >= chars
					return input.substring(0, chars).trim() + '...'
				return input

		app.register.filter 'startFrom', ->
			return (input, start) ->
				if input
					start = +start
					return input.slice(start)
				return []

		app.register.filter 'readableNumber', ->
			return (input, scope) ->
				if input
					return parseInt(input).format(0, ' ')
				return "0"