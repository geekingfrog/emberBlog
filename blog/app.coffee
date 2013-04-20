window.App = Ember.Application.create({
  serviceUrl: "http://geekingfrog.com"
})



# basic mixin to provide additional properties
# to the records loaded from the backend
App.CanModel = Ember.ObjectProxy.extend({
  isLoaded: false
  isNew:(->@get('content.id')?).property('content.id')
  isSaving: false
  isError: false
})

# similar to ModelMixin
# App.ModelListMixin = Ember.Mixin.create({
App.CanModelList = Ember.ArrayProxy.extend({
  isLoaded: Ember.computed ->
    return false unless @get('content')?
    return @get('content').everyProperty('isLoaded', true)
  .property('content', 'content.@each.isLoaded')
  isError: false
})

# Function to be called with reopenClass to add the basic functionalities
# for the model classes (store, and method to materialize models from hash)
makeCanModel = ->
  store = {}
  model = (hash) ->
    record = store[hash.id]
    unless record
      record = @create({content: hash})
      store[hash.id] = record
    return record
  models = (hashArray) ->
    self = this
    newModels = _.map(hashArray, (hash) -> self.model(hash))
    return Ember.A(newModels)
  return {
    store: store
    model: model
    models: models
  }


# For an arrayController whose content is an instance of CanModelList,
# provide computed properties to avoid fetching content.isLoaded
# (this is only syntaxic sugar, and a little training)
App.ArrayModelController = Ember.ArrayController.extend({
  isLoaded: Ember.computed ->
    @get('content').get('isLoaded')
  .property('content.isLoaded')

  isError: Ember.computed ->
    @get('content').get('isError')
  .property('content.isError')
})


# Post model
App.Post = App.CanModel.extend()
App.Post.reopenClass(makeCanModel())
App.Post.reopenClass({
  find: (id) ->
    return @findAll() unless id?
    record = @model({id: id})
    finding = $.getJSON("#{App.get('serviceUrl')}?json=get_post&post_id=#{id}")
    finding.done (hash) ->
      record.setProperties({
        isLoaded: true
        content: hash.post
      })
    return record

  findAll: ->
    res = App.CanModelList.create()
    finding = $.getJSON("#{App.get('serviceUrl')}?json=get_recent_post")
    finding.done (data) =>
      console.log "calling models with this: ",this
      models = Ember.A(@models(data.posts))
      models.setEach('isLoaded', true)
      res.set('content', models)
    return res
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
    
App.NavmenuController = App.ArrayModelController.extend()

