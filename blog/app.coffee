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
makeCanModel = (options={}) ->
  type = this
  console.log "Generating model's features for #{type}"
  name = type.toString().slice(type.toString().lastIndexOf('.')+1).camelize()
  plural = options.plural or name+'s'
  store = {}
  model = (hash) ->
    record = store[hash.id]
    unless record
      # console.log "create #{this} for id: #{hash.id} (#{typeof hash.id}) with hash:",hash
      record = @create({content: hash})
      store[hash.id] = record
    return record

  # returns the content of the store if the provided array is null
  models = (hashArray) ->
    # console.log "creating models for #{type} with hash: ", hashArray
    unless hashArray
      fromStore = Ember.A([])
      for key, val of @store
        fromStore.push val
      return fromStore
    self = this
    newModels = _.map(hashArray, (hash) -> self.model(hash))
    return Ember.A(newModels)


  findAll = ->
    res = App.CanModelList.create({content: type.models()})
    findAllUrl = options.url?.findAll or
      "#{App.get('serviceUrl')}?json=get_#{name}_index"

    finding = $.getJSON(findAllUrl)
    finding.done (data) =>
      models = type.models(data[plural])
      models.setEach('isLoaded', true)
      res.set('content', models)
    return res

  find = (id) ->
    return findAll() unless id?
    record = type.model({id: id})
    return record if record.get('isLoaded')
    findUrl = options.url?.find or
      "#{App.get('serviceUrl')}?json=get_#{name}&#{name}_id=#{id}"
    finding = $.getJSON(findUrl)
    finding.done (data) =>
      record.setProperties({
        isLoaded: true
        content: data[name]
      })
    return record

  return {
    store: store
    model: model
    models: models
    find: find
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
App.Post.reopenClass(makeCanModel.call(App.Post, {
  url: {findAll: "#{App.get('serviceUrl')}?json=get_recent_posts"}
  }))

# category model
App.Category = App.CanModel.extend()
App.Category.reopenClass(makeCanModel.call(App.Category, {
  plural: 'categories'
  }))

# Tags model
App.Tag = App.CanModel.extend()
App.Tag.reopenClass(makeCanModel.call(App.Tag))

# Author model
App.Author = App.CanModel.extend()
App.Author.reopenClass(makeCanModel.call(App.Author))


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


