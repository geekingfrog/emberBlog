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
# Also create the find method based on the given options.
# It expect the url to be like App.serviceUrl?json=get_{name}&{name}_id=:id
# or get_{name}_index for findAll. The url can be changed in options.url.find and
# options.url.findAll
#
# It expects the response to be like
# {
#   status: 'ok',
#   root: [data...]
# }
# where root is the {name} for find and {plural} for findAll. {plural} is {name}s
# If the plural is irregular, it is options.plural
# If the id is not 'id', it can be specified in the options, eg:
# {id: 'ID'}
makeCanModel = (options={}) ->
  type = this
  console.log "Generating model's features for #{type}"
  name = type.toString().slice(type.toString().lastIndexOf('.')+1).camelize()
  plural = options.plural or name+'s'
  classId = options.id or 'id'
  store = {}
  model = (hash, loaded = false) ->
    return unless hash?
    id = hash[classId]
    hash.id = hash[classId]
    record = store[id]
    unless record
      # console.log "create #{this} for id: #{hash.id} (#{typeof hash.id}) with hash:",hash
      hash.id = hash[classId]
      record = @create({isLoaded: loaded, content: hash})
      store[id] = record
    return record

  # returns the content of the store if the provided array is null
  models = (hashArray, loaded = false) ->
    # console.log "creating models for #{type} with hash: ", hashArray
    unless hashArray
      fromStore = Ember.A([])
      for key, val of type.store
        fromStore.push val
      return fromStore
    self = this
    newModels = _.map(hashArray, (hash) -> self.model(hash, loaded))
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
    modelArgs = {}
    modelArgs[classId] = id
    record = type.model(modelArgs)
    return record if record.get('isLoaded')
    findUrl = options.url?.find
    if findUrl
      findUrl = findUrl.replace(/:[^&]+/i,id)
    else
      "#{App.get('serviceUrl')}?json=get_#{name}&#{name}_#{classId}=#{id}"
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


################################################################################ 
# Models definition
################################################################################ 
App.Post = App.CanModel.extend()
App.Post.reopenClass(makeCanModel.call(App.Post, {
  url: {
    findAll: "#{App.get('serviceUrl')}?json=get_recent_posts"
    find: "#{App.get('serviceUrl')}?json=get_post&post_slug=:slug"
  }
  id: 'slug'
}))
App.Post.reopenClass({
  model: (hash) ->
    hash.categories = App.Category.models(hash.categories, true)
    hash.author = App.Author.model(hash.author, true)
    hash.tags = App.Tag.models(hash.tags, true)
    record = @_super(hash)
})

App.Category = App.CanModel.extend()
App.Category.reopenClass(makeCanModel.call(App.Category, {
  plural: 'categories'
  id: 'slug'
}))

App.Tag = App.CanModel.extend()
App.Tag.reopenClass(makeCanModel.call(App.Tag, {
  id: 'slug'
}))

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


