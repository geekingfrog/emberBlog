window.App = Ember.Application.create({
  serviceURL: "http://geekingfrog.com"
})

################################################################################ 
# Router
################################################################################ 
App.Router.map ->
  @resource('posts', ->
    @resource('post', {path: ':post_id'}
    )
  )

App.ApplicationRoute = Ember.Route.extend({
  setupController: ->
    # @controllerFor('posts').set('model', App.Post.find())
    @controllerFor('navmenu').set('model', App.Post.find())
})

App.PostsRoute = Ember.Route.extend({
  model: -> App.Post.find()
  setupController: (controller, model) ->
    @_super controller, model
})

App.PostRoute = Ember.Route.extend({
  model: (params) ->
    console.log "params: ", params
    App.Post.find(params.post_id)
})


App.PostsController = Ember.ArrayController.extend()

App.NavmenuController = Ember.ArrayController.extend({
  test: 'bar bar bar'
})
 


################################################################################ 
# Data model
################################################################################ 
# App.Post = Ember.Object.extend()
# App.Post.reopenClass({
#   findRecent: ->
#     def = $.getJSON("#{App.get('serviceURL')}?json=get_recent_posts")
#     return def.then((response) -> return response.posts).promise()
# })

App.Store = DS.Store.extend({
  revision: 12
  adapter: 'DS.FixtureAdapter'
})

App.Post = DS.Model.extend({
  title: DS.attr('string')
  categories: DS.hasMany('App.Category')
})

App.Category = DS.Model.extend({
  slug: DS.attr 'string'
  title: DS.attr 'string'
  post_count: DS.attr 'number'
  parent: DS.belongsTo('App.Category')
})

App.Tag = DS.Model.extend({
  slug: DS.attr 'string'
  title: DS.attr 'string'
  post_count: DS.attr 'number'
})

App.Post.FIXTURES = [
  {id: 230, title: "Some notes about Kriskowal&#8217;s Q", categories: {id: 4}}
  {id: 233, title: "Vim update"}
  {id: 221, title: "Famous people in the appledaily"}
  {id: 211, title: "Crash Course on Web Performance"}
  {id: 203, title: "inotify cannot be used; too many open files"}
  {id: 197, title: "github coursera assignments"}
  {id: 190, title: "git svn and perl bindings"}
  {id: 185, title: "Scala and functional programming"}
  {id: 181, title: "Akka camel actor and preStart method"}
  {id: 170, title: "Akka &#8211; typedActor with customed supervision"}
]


App.Category.FIXTURES = [
  {
    id: 3
    slug: "chinese"
    title: "chinese"
    description: ""
    parent: 0
    post_count: 1
  }, {
    id: 4
    slug: "geek"
    title: "geek"
    description: ""
    parent: 0
    post_count: 26
  }, {
    id: 5
    slug: "how-to"
    title: "how to"
    description: ""
    parent: 0
    post_count: 1
  }, {
    id: 6
    slug: "life"
    title: "life"
    description: ""
    parent: 0
    post_count: 2
  }, {
    id: 7
    slug: "web"
    title: "web"
    description: ""
    parent: 0
    post_count: 3
  }, {
    id: 8
    slug: "work"
    title: "work"
    description: ""
    parent: 6
    post_count: 3
  }
]


App.Tag.FIXTURES = [
  {
    id: 9
    slug: "actor"
    title: "actor"
    description: ""
    post_count: 1
  }, {
    id: 10
    slug: "akka"
    title: "akka"
    description: ""
    post_count: 2
  }, {
    id: 11
    slug: "apache"
    title: "apache"
    description: ""
    post_count: 2
  }, {
    id: 62
    slug: "appledaily"
    title: "appledaily"
    description: ""
    post_count: 1
  }, {
    id: 12
    slug: "bash"
    title: "bash"
    description: ""
    post_count: 2
  }, {
    id: 13
    slug: "bepo"
    title: "b\u00e9po"
    description: ""
    post_count: 1
  }, {
    id: 14
    slug: "camel"
    title: "camel"
    description: ""
    post_count: 1
  }, {
    id: 15
    slug: "coding"
    title: "coding"
    description: ""
    post_count: 1
  }, {
    id: 16
    slug: "commonspooltargetsource"
    title: "CommonsPoolTargetSource"
    description: ""
    post_count: 1
  }, {
    id: 17
    slug: "configuration"
    title: "configuration"
    description: ""
    post_count: 1
  }, {
    id: 18
    slug: "coursera"
    title: "coursera"
    description: ""
    post_count: 2
  }, {
    id: 19
    slug: "cxf"
    title: "cxf"
    description: ""
    post_count: 1
  }, {
    id: 64
    slug: "d3"
    title: "d3"
    description: ""
    post_count: 1
  }, {
    id: 20
    slug: "dating"
    title: "dating"
    description: ""
    post_count: 1
  }, {
    id: 69
    slug: "defer"
    title: "defer"
    description: ""
    post_count: 1
  }, {
    id: 21
    slug: "eclipse"
    title: "eclipse"
    description: ""
    post_count: 1
  }, {
    id: 22
    slug: "effective-java"
    title: "effective java"
    description: ""
    post_count: 1
  }, {
    id: 23
    slug: "facebook"
    title: "Facebook"
    description: ""
    post_count: 1
  }, {
    id: 24
    slug: "feichengwurao"
    title: "feichengwurao"
    description: ""
    post_count: 1
  }, {
    id: 25
    slug: "ftp"
    title: "ftp"
    description: ""
    post_count: 1
  }, {
    id: 26
    slug: "fun"
    title: "fun"
    description: ""
    post_count: 1
  }, {
    id: 27
    slug: "g"
    title: "g+"
    description: ""
    post_count: 1
  }, {
    id: 4
    slug: "geek"
    title: "geek"
    description: ""
    post_count: 8
  }, {
    id: 28
    slug: "git"
    title: "git"
    description: ""
    post_count: 1
  }, {
    id: 29
    slug: "google"
    title: "google +"
    description: ""
    post_count: 1
  }, {
    id: 30
    slug: "google-plus"
    title: "Google plus"
    description: ""
    post_count: 1
  }, {
    id: 31
    slug: "history"
    title: "history"
    description: ""
    post_count: 1
  }, {
    id: 32
    slug: "java"
    title: "java"
    description: ""
    post_count: 4
  }, {
    id: 68
    slug: "javascript"
    title: "javascript"
    description: ""
    post_count: 1
  }, {
    id: 60
    slug: "lsof"
    title: "lsof"
    description: ""
    post_count: 1
  }, {
    id: 34
    slug: "maven"
    title: "maven"
    description: ""
    post_count: 2
  }, {
    id: 63
    slug: "mongodb"
    title: "mongodb"
    description: ""
    post_count: 1
  }, {
    id: 35
    slug: "mysql"
    title: "MySQL"
    description: ""
    post_count: 1
  }, {
    id: 36
    slug: "nfc"
    title: "nfc"
    description: ""
    post_count: 1
  }, {
    id: 72
    slug: "node"
    title: "node"
    description: ""
    post_count: 1
  }, {
    id: 61
    slug: "node-js"
    title: "node.js"
    description: ""
    post_count: 2
  }, {
    id: 37
    slug: "objectpool"
    title: "objectPool"
    description: ""
    post_count: 1
  }, {
    id: 38
    slug: "project-euler"
    title: "project euler"
    description: ""
    post_count: 1
  }, {
    id: 70
    slug: "promise"
    title: "promise"
    description: ""
    post_count: 1
  }, {
    id: 71
    slug: "q"
    title: "q"
    description: ""
    post_count: 1
  }, {
    id: 39
    slug: "rails"
    title: "rails"
    description: ""
    post_count: 2
  }, {
    id: 40
    slug: "ruby"
    title: "ruby"
    description: ""
    post_count: 2
  }, {
    id: 41
    slug: "scala"
    title: "scala"
    description: ""
    post_count: 2
  }, {
    id: 66
    slug: "snippets"
    title: "snippets"
    description: ""
    post_count: 1
  }, {
    id: 42
    slug: "social-network"
    title: "social network"
    description: ""
    post_count: 1
  }, {
    id: 43
    slug: "social-website"
    title: "social website"
    description: ""
    post_count: 1
  }, {
    id: 73
    slug: "socket-io"
    title: "socket.io"
    description: ""
    post_count: 1
  }, {
    id: 44
    slug: "spring"
    title: "spring"
    description: ""
    post_count: 1
  }, {
    id: 45
    slug: "ssh"
    title: "ssh"
    description: ""
    post_count: 2
  }, {
    id: 46
    slug: "ssh-agent"
    title: "ssh agent"
    description: ""
    post_count: 1
  }, {
    id: 47
    slug: "subclipse"
    title: "subclipse"
    description: ""
    post_count: 1
  }, {
    id: 48
    slug: "supervisor"
    title: "supervisor"
    description: ""
    post_count: 1
  }, {
    id: 49
    slug: "svn"
    title: "svn"
    description: ""
    post_count: 3
  }, {
    id: 50
    slug: "synergy"
    title: "synergy"
    description: ""
    post_count: 1
  }, {
    id: 51
    slug: "tomcat"
    title: "tomcat"
    description: ""
    post_count: 1
  }, {
    id: 52
    slug: "toro"
    title: "toro"
    description: ""
    post_count: 1
  }, {
    id: 53
    slug: "tutorial"
    title: "tutorial"
    description: ""
    post_count: 2
  }, {
    id: 54
    slug: "tv-show"
    title: "TV show"
    description: ""
    post_count: 1
  }, {
    id: 55
    slug: "typed-actor"
    title: "typed actor"
    description: ""
    post_count: 1
  }, {
    id: 67
    slug: "ultisnips"
    title: "ultisnips"
    description: ""
    post_count: 1
  }, {
    id: 65
    slug: "vim"
    title: "vim"
    description: ""
    post_count: 1
  }, {
    id: 56
    slug: "virtualization"
    title: "virtualization"
    description: ""
    post_count: 2
  }, {
    id: 57
    slug: "web-service"
    title: "web service"
    description: ""
    post_count: 1
  }, {
    id: 8
    slug: "work"
    title: "work"
    description: ""
    post_count: 1
  }, {
    id: 58
    slug: "xen"
    title: "xen"
    description: ""
    post_count: 2
  }, {
    id: 59
    slug: "%e9%9d%9e%e8%af%9a%e5%8b%bf%e6%89%b0"
    title: "\u975e\u8bda\u52ff\u6270"
    description: ""
    post_count: 1
  }
]

window.t = ->
  $.getJSON("http://geekingfrog.com/?json=get_recent_post").done (response) ->
    console.log "done"
    window.d = response.posts.map (p) ->
      return {id: p.id, slug: p.slug, title: p.title}
    for p in d
      console.log "{id: #{p.id}, title: \"#{p.title}\""



