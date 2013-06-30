# oauthd
# http://oauth.io
#
# Copyright (c) 2013 thyb, bump
# Licensed under the MIT license.

async = require 'async'

exports.setup = (callback) ->

	@db.timelines = require './db_timelines'

	@on 'connect.callback', (data) =>
		@db.timelines.addUse target:'co:a:' + data.key + ':' + data.status, (->)
		@db.timelines.addUse target:'co:p:' + data.provider + ':' + data.status, (->)
		@db.timelines.addUse target:'co:a:' + data.key + ':p:' + data.provider + ':' + data.status, (->)

	@on 'connect.auth', (data) =>
		@db.timelines.addUse target:'co:p:' + data.provider, (->)
		@db.timelines.addUse target:'co:a:' + data.key + ':p:' + data.provider, (->)
		@db.timelines.addUse target:'co:a:' + data.key, (->)

	sendStats = @check target:'string', unit:['string','none'], start:'int', end:['int','none'], (data, callback) =>
		now = Math.floor((new Date).getTime() / 1000)
		data.unit ?= 'd'
		data.end ?= now

		err = new @check.Error
		err.error 'unit', 'invalid unit type' if data.unit != 'm' && data.unit != 'd' && data.unit != 'h'
		err.error 'end', 'invalid format' if data.end > now + 12 * 31 * 24 * 3600 * 24
		return callback err if err.failed()

		if data.unit == 'm' && data.end - data.start > 50 * 31 * 24 * 3600 ||
			data.unit == 'd' && data.end - data.start > 50 * 24 * 3600 ||
			data.unit == 'h' && data.end - data.start > 50 * 3600
				return callback new @check.Error 'Too large date range'

		async.parallel [
			(cb) => @db.timelines.getTimeline data.target, data, cb
			(cb) => @db.timelines.getTimeline data.target + ':success', data, cb
			(cb) => @db.timelines.getTimeline data.target + ':error', data, cb
		], (e, r) ->
			return callback e if e
			res = labels:Object.keys(r[0]), ask:[], success:[], fail:[]
			for k,v of r[0]
				res.ask.push v
				res.success.push r[1][k]
				res.fail.push r[2][k]
			callback null, res

	# get statistics for an app
	@server.get @config.base + '/api/apps/:key/stats', @auth.adm, (req, res, next) =>
		req.params.target = 'co:a:' + req.params.key
		sendStats req.params, @server.send(res, next)

	# get statistics for a keyset
	@server.get @config.base + '/api/apps/:key/keysets/:provider/stats', @auth.adm, (req, res, next) =>
		req.params.target = 'co:a:' + req.params.key + ':p:' + req.params.provider
		sendStats req.params, @server.send(res, next)

	# get statistics for a provider
	@server.get @config.base + '/api/providers/:provider/stats', @auth.adm, (req, res, next) =>
		req.params.target = 'co:p:' + req.params.provider
		sendStats req.params, @server.send(res, next)

	callback()