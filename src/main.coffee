# Description:
#   Push newrelic alerts to your channel
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_NEWRELIC_ALERTS_API_KEY - Token to verify pushes
#   HUBOT_NEWRELIC_ALERTS_DEFAULT_ROOM - The default room where messages should be pushed
#   HUBOT_NEWRELIC_ALERTS_ROOM_MAPPING - Stringified JSON { "app_name": "room" } (rooms delimetered by ,)
#
# URLS:
#   POST /hubot/newrelic_alerts?token=<token>
#
# Author:
#   kruczjak

querystring = require('querystring')
url = require('url')

module.exports = (robot) ->
  robot.router.post "/hubot/newrelic_alerts", (req, res) ->
    query = querystring.parse(url.parse(req.url).query)

    return res.end("{ error: 403 }") if query.token != process.env["HUBOT_NEWRELIC_ALERTS_API_KEY"]
    
    data = req.body
    for i of data
      alertStringJson = data[i]
      alertType = i
      alert = JSON.parse(alertStringJson)

      appName = alert?['application_name']?.replace(/[^a-zA-Z0-9]/g, '_')

      roomMapping = JSON.parse(process.env["HUBOT_NEWRELIC_ALERTS_ROOM_MAPPING"])
      rooms = roomMapping?[appName]?.split(',') || [process.env["HUBOT_NEWRELIC_ALERTS_DEFAULT_ROOM"]]

      console.log(alert)
      console.log(alertType)

      for room in rooms
        switch alertType
          when 'alert'
            message = alert['message']
            shortDescription = alert['short_description']
            originalAppName = alert['application_name']

            robot.messageRoom room, "#{originalAppName}\n#{message}\n#{shortDescription}"

      res.end "{ success: 200 }"