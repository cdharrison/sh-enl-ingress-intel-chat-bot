async = require 'async'
moment = require 'moment'

plugin = 

    name: 'tracker'

    init: (callback) ->

        Bot.Server.get '/tracker/:player/:mintimestampms/:maxtimestampms', AccessLevel.LEVEL_TRUSTED, 'Track a player', (req, res) ->

            player = req.params.player
            minMs = parseInt req.params.mintimestampms
            maxMs = parseInt req.params.maxtimestampms

            async.series [

                # update to correct letter-case
                (callback) ->

                    Database.db.collection('Agent').findOne
                        _id: new RegExp('^' + player + '$', 'i')
                    , (err, agent) ->

                        return callback() if err or not agent
                        player = agent._id
                        callback()

                (callback) ->

                    Database.db.collection('Chat.Public').find
                        'markup.PLAYER1.plain': player
                        'time':
                            $gte: minMs
                            $lte: maxMs
                    .sort
                        time: -1
                    .toArray (err, records) ->

                        for rec in records
                            rec.time_str = moment(rec.time).format 'LLLL' if rec.time?

                        res.jsonp records

            ]

        Bot.Server.get '/tracker/:player/:page', AccessLevel.LEVEL_TRUSTED, 'Track a player', (req, res) ->

            player = req.params.player
            page = parseInt req.params.page

            async.series [

                # update to correct letter-case
                (callback) ->

                    Database.db.collection('Agent').findOne
                        _id: new RegExp('^' + player + '$', 'i')
                    , (err, agent) ->

                        return callback() if err or not agent
                        player = agent._id
                        callback()

                (callback) ->

                    Database.db.collection('Chat.Public').find
                        'markup.PLAYER1.plain': player
                    .sort
                        time: -1
                    .skip   (page - 1) * Config.Tracker.PageSize
                    .limit  Config.Tracker.PageSize
                    .toArray (err, records) ->

                        for rec in records
                            rec.time_str = moment(rec.time).format 'LLLL' if rec.time?

                        res.jsonp records

            ]

        callback()

module.exports = plugin