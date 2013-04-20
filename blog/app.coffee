window.App = Ember.Application.create({
  serviceUrl: "http://geekingfrog.com"
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
    window.t = App.Post.find()
    @controllerFor('navmenu').set('model', t)
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
  test: 'foo'
})
 

# basic mixin to provide additional properties
# to the records loaded from the backend
App.BasicModel = Ember.ObjectProxy.extend({
  isLoaded: false
  isSaving: false
  isNew: true
  isError: false
  load: (hash) ->
    @set('isLoaded', true)
    @set('isNew', false)
    @set('content', hash)
    return
})

# similar to ModelMixin
# App.ModelListMixin = Ember.Mixin.create({
App.BasicModelList = Ember.ArrayProxy.extend({
  content: []
  # get an array of hash and returns an array of records
  # If the record exists, it is looked up in the store first
  # otherwise, a new record is created and put in the store
  createAndLoad: (hashList, type) ->
    materializedChildren = _.map(hashList, (hash) ->
      record = type.store[hash.id]
      unless record
        # console.log "creating a new record from: ", hash
        record = type.create()
        type.store[hash.id] = record
      record.load(hash)
      return record
    )
    @set('content', materializedChildren)
    return
})

# utility to create the most common methods on a model
# expects a hash of methodName: {url, params}
# and the root where to find the response
# Example:
# you want to retrieve data at the url:
# www.example.com?json=get_posts
# and the response format is:
# {
#   status: 'ok
#   posts: [{id: '1'}]
# }
#
# You would then call
# createModelMethods({findAll: {url: "www.example.com?json=get_posts}}, 'posts')
#
createModelMethods = (methods, root) ->
  console.log "create methods for root: #{root}"
  o = {}
  store = {}
  o.store = store
  
  # findAll
  if methods.findAll
    o.findAll = do ->
      # all = Ember.ArrayProxy.createWithMixins(App.ModelListMixin, { content: [] })
      all = App.BasicModelList.create()
      return ->
        finding = $.getJSON(methods.findAll.url)
        finding.done (data) =>
          console.log "executing findAll, this: ", this
          all.createAndLoad(data[root], this)
        return all
      
  # find, default to findAll if no id is provided
  if not methods.find and methods.findAll
    o.find = (id) ->
      if id?
        throw new Error("find(id) is not implemented for #{this}, call find() instead")
      return @findAll()
  if methods.find and methods.findAll
    o.find = (id) ->
      return @findAll() unless id?

  return o



App.Category = App.BasicModel.extend()

App.Category.reopenClass(createModelMethods({
  findAll: {url: "#{App.get('serviceUrl')}?json=get_category_index"}
}, 'categories'))

# App.Category.find()

App.Post = App.BasicModel.extend()
App.Post.reopenClass(createModelMethods({
  findAll: {url: "#{App.get('serviceUrl')}?json=get_recent_post"}
}, 'posts'))



