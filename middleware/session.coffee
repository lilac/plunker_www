request = require("request")
nconf = require("nconf")
url = require("url")


module.exports.middleware = (options = {}) ->

  console.log url.parse(nconf.get("url:www"))

  apiUrl = nconf.get("url:api")
  domain = url.parse(nconf.get("url:www")).hostname
  self = @
  
  middleware = (req, res, next) ->
    handleRequest = (err, innerRes, body) ->
      return next(err) if err
      
      exposeSession body if body
      
      next()
      
    createSession = ->
      request.post "#{apiUrl}/sessions", json: true, handleRequest
      
    exposeSession = (data) ->
      console.log "plnkrsessid", data.id,
        domain: domain
        expires: new Date(Date.now() + 1000 * 60 * 60 * 24 * 14)
    
      res.cookie "plnkrsessid", data.id,
        domain: domain
        expires: new Date(Date.now() + 1000 * 60 * 60 * 24 * 14)
      
      res.expose data, "_plunker.session"
  
    if sessid = req.cookies.plnkrsessid
      request.get "#{apiUrl}/sessions/#{sessid}", json: true, handleRequest
    else
      createSession()