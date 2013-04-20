express = require('express')
server = express()
logger = require './logConfig'


basedir = require('path').normalize("#{__dirname}/../blog")
logger.info "basedir: #{basedir}"

httpServer = require('http').createServer(server)
io = require('socket.io').listen(httpServer)

watch = require('node-watch')
filter = (pattern, fun) ->
  return (filename) ->
    if pattern.test(filename)
      fun(filename)
 
watch('./', filter(/\.js|\.css$|\.html$/i, ->
  io.sockets.emit('reload')
))

server.use(server.router)
server.use(express.directory basedir)
server.use(express.static basedir)


httpServer.listen(4445)
logger.info "Server up and running on port 4445"
