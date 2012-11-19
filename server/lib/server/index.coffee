{argv} = require 'optimist'

{webserver, mongo, mq, projectRoot, kites, uploads, basicAuth} = require argv.c

webPort = argv.p ? webserver.port

{extend} = require 'underscore'
express = require 'express'
Broker = require 'broker'
# Bongo = require 'bongo'
gzippo = require 'gzippo'
fs = require 'fs'
hat = require 'hat'
nodePath = require 'path'

app = express()

# this is a hack so express won't write the multipart to /tmp
#delete express.bodyParser.parse['multipart/form-data']

app.configure ->
  app.use express.cookieParser()
  app.use express.session {"secret":"foo"}
  app.use express.bodyParser()
  app.use express.compress()
  app.use express.static "#{projectRoot}/website/"

#app.use gzippo.staticGzip "#{projectRoot}/website/"
app.use (req, res, next)->
  res.removeHeader("X-Powered-By")
  next()

if basicAuth
  app.use express.basicAuth basicAuth.username, basicAuth.password

process.on 'uncaughtException',(err)->
  console.log 'there was an uncaught exception'
  throw err
  console.trace()

koding = require './bongo'

kiteBroker =\
  if kites?.vhost?
    new Broker extend {}, mq, vhost: kites.vhost
  else
    koding.mq

koding.mq.connection.on 'ready', ->
  console.log 'message broker is ready'

authenticationFailed = (res, err)->
  res.send "forbidden! (reason: #{err?.message or "no session!"})", 403

app.get "/Logout", (req, res)->
  res.clearCookie 'clientId'
  res.redirect 302, '/'

app.get '/Auth', (req, res)->
  crypto = require 'crypto'
  {JSession} = koding.models
  channel = req.query?.channel
  return res.send 'user error', 400 unless channel?
  clientId = req.cookies.clientId
  JSession.fetchSession clientId, (err, session)->
    if session? and clientId isnt session?.clientId
      res.cookie 'clientId', session.clientId
    if err
      authenticationFailed(res, err)
    else
      [priv, type, pubName] = channel.split '-'
      if /^bongo\./.test type
        privName = 'secret-bongo-'+hat()+'.private'
        koding.mq.funnel privName, koding.queueName
        res.send privName
      else unless session?
        authenticationFailed(res)
      else if type is 'kite'
        {username} = session
        cipher = crypto.createCipher('aes-256-cbc', '2bB0y1u~64=d|CS')
        cipher.update(
          ''+pubName+req.cookies.clientid+Date.now()+Math.random()
        )
        privName = ['secret', 'kite', cipher.final('hex')+".#{username}"].join '-'
        privName += '.private'

        bindKiteQueue = (binding, callback) ->
          kiteBroker.bindQueue(
            privName, privName, binding,
            {queueDurable:no, queueExclusive:no},
            callback
            )

        bindKiteQueue "client-message", (kiteCmQueue1, exchangeName)->
          kiteCmQueue1.close() # this will get opened back up?
          bindKiteQueue "disconnected", (kiteCmQueue2, exchangeName) ->
            kiteBroker.emit(channel, 'join', {user: username, queue: privName})

            kiteBroker.connection.on 'error', console.log
            kiteBroker.createQueue '', (dcQueue)->
              dcQueue.bind exchangeName, 'disconnected'
              dcQueue.subscribe ->
                dcQueue.destroy()#.addCallback -> dcQueue.close()
                setTimeout ->
                  kiteCmQueue2.destroy()#.addCallback -> kiteCmQueue.close()
                , kites?.disconnectTimeout ? 5000
            return res.send privName

if uploads?.enableStreamingUploads
  
  s3 = require('./s3') uploads.s3

  app.post '/upload', s3..., (req, res)->
    res.send(for own key, file of req.files
      filename  : file.filename
      resource  : nodePath.join uploads.distribution, file.path
    )

  app.get '/upload/test', (req, res)->
    res.send \
      """
      <script>
        function submitForm(form) {
          var file, fld;
          input = document.getElementById('image');
          file = input.files[0];
          fld = document.createElement('input');
          fld.hidden = true;
          fld.name = input.name + '-size';
          fld.value = file.size;
          form.appendChild(fld);
          return true;
        }
      </script>
      <form method="post" action="/upload" enctype="multipart/form-data" onsubmit="return submitForm(this)">
        <p>Title: <input type="text" name="title" /></p>
        <p>Image: <input type="file" name="image" id="image" /></p>
        <p><input type="submit" value="Upload" /></p>
      </form>
      """

app.get "/", (req, res)->
  if frag = req.query._escaped_fragment_?
    res.send 'this is crawlable content'
  else
    # log.info "serving index.html"
    res.header 'Content-type', 'text/html'
    fs.readFile "#{projectRoot}/website/index.html", (err, data) ->
      throw err if err
      res.send data

app.get "/status/:data",(req,res)->
  # req.params.data

  # connection.exchange 'public-status',{autoDelete:no},(exchange)->
  # exchange.publish 'exit','sharedhosting is dead'
  # exchange.close()
  koding.mq.emit 'public-status','exit',req.params.data
  res.send "alright."

app.get "/api/user/:username/flags/:flag", (req, res)->
  {username, flag} = req.params
  {JAccount}       = koding.models

  JAccount.one "profile.nickname" : username, (err, account)->
    if err or not account
      state = false
    else
      state = account.checkFlag('super-admin') or account.checkFlag(flag)
    res.end "#{state}"

getAlias =(url)->

  console.log 'url', url
  # url = url.replace /^\/, ''
  # if url in ['auth']


app.get '*', (req,res)->
  {url} = req
  alias = getAlias req.url
  query = url.slice 
  res.header 'Location', "/#!#{alias ? req.url}#{query}"
  res.send 302

app.listen webPort

console.log 'Koding Webserver running ', "http://localhost:#{webPort}"
