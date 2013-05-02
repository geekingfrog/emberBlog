# require all templates compiled with ember_templates
require './templates'

window.App = Ember.Application.create({
  serviceUrl: "http://geekingfrog.com"
})

# require './models/canModel'
# require './models/post'
require './posts/post'
require './category/category'
require './archives/archives'
require './sideMenu/sideMenu'

App.Router.map ->
  @resource('posts', ->
    @resource('post', {path: ':post_id'})
  )

  @resource('tags', ->
    @resource('tag', {path: ":tag_id"})
  )
  
  @resource('category', {path: "/category/:category_id"})

  @resource('archives', ->
    @resource('year', {path: ':y'}, ->
      @resource('month', {path: ':m'})
    )
  )

  @route("fourOhFour", {path: "*:"})

App.IndexRoute = Ember.Route.extend
  redirect: -> @transitionTo 'posts'

App.ApplicationRoute = Ember.Route.extend(
  renderTemplate: ->
    console.log "seting up controllers for the side menu"
    @render 'application'
    @render 'sideMenu', {
      into: 'application'
      outlet: 'sideMenu'
      controller: 'sideMenu'
    }
)
# App.Post.find()


# # basic mixin to provide additional properties
# # to the records loaded from the backend
# App.CanModel = Ember.ObjectProxy.extend({
#   isLoaded: false
#   isNew:(->@get('content.id')?).property('content.id')
#   isSaving: false
#   isError: false
# })
# 
# # similar to ModelMixin
# # App.ModelListMixin = Ember.Mixin.create({
# App.CanModelList = Ember.ArrayProxy.extend({
#   count: undefined
#   isLoaded: false
#   isError: false
# })
# 
# # Function to be called with reopenClass to add the basic functionalities
# # for the model classes (store, and method to materialize models from hash)
# # Also create the find method based on the given options.
# # It expect the url to be like App.serviceUrl?json=get_{name}&{name}_id=:id
# # or get_{name}_index for findAll. The url can be changed in options.url.find and
# # options.url.findAll
# #
# # It expects the response to be like
# # {
# #   status: 'ok',
# #   root: [data...]
# # }
# # where root is the {name} for find and {plural} for findAll. {plural} is {name}s
# # If the plural is irregular, it is options.plural
# # If the id is not 'id', it can be specified in the options, eg:
# # {id: 'ID'}
# #
# # If in the response from the server is embedded another object, one can override the
# # function materialize, which take the hash of the original object and return
# # the hash where the nested object have been converted to ember object.
# makeCanModel = (options={}) ->
#   type = this
#   console.log "Generating model's features for #{type}"
#   name = type.toString().slice(type.toString().lastIndexOf('.')+1).camelize()
#   plural = options.plural or name+'s'
#   classId = options.id or 'id'
#   store = {}
# 
#   # function to materialize embedded objects. By default, it just returns the given hash
#   # If one have the author embedded inside a post, he can create a record for the author
#   # by overriding materialize:
#   # (hash) -> hash.author = App.Author.model(hash.author)
#   materialize = (hash) -> hash
# 
#   model = (hash, loaded = false) ->
#     return unless hash?
#     type.materialize(hash)
#     hash.id = hash[classId]
#     record = store[hash.id]
#     # console.log "create #{this} for id: #{hash.id} (#{typeof hash.id}) with hash:",hash
#     unless record
#       record = @create({isLoaded: loaded, content: hash})
#     store[hash.id] = record
#     record.set('isLoaded', loaded)
#     return record
# 
#   # returns the content of the store if the provided array is null
#   models = (hashArray, loaded = false) ->
#     # console.log "models of #{type} called with hasharray : ", hashArray, ' store: ', type.store
#     unless hashArray
#       fromStore = Ember.A([])
#       for key, val of type.store
#         fromStore.push val
#       return fromStore
#     self = this
#     newModels = _.map(hashArray, (hash) -> self.model(hash, loaded))
#     return Ember.A(newModels)
# 
# 
#   findAll = ->
#     res = App.CanModelList.create()
#     findAllUrl = options.url?.findAll or
#       "#{App.get('serviceUrl')}?json=get_#{name}_index"
# 
#     finding = $.getJSON(findAllUrl)
#     finding.done (data) =>
#       models = type.models(data[plural], true)
#       res.setProperties({
#         content: models
#         count: data.count
#         isLoaded: true
#       })
#     return res
# 
#   find = (id) ->
#     return findAll() unless id?
#     modelArgs = {}
#     modelArgs[classId] = id
#     record = type.model(modelArgs)
#     return record if record.get('isLoaded')
#     findUrl = options.url?.find
#     if findUrl
#       findUrl = findUrl.replace(/:[^/&]+/i,id)
#     else
#       "#{App.get('serviceUrl')}?json=get_#{name}&#{name}_#{classId}=#{id}"
#     finding = $.getJSON(findUrl)
#     finding.done (data) =>
#       newHash = type.materialize(data[name])
#       record.setProperties({
#         isLoaded: true
#         content: newHash
#       })
#       return
#     return record
# 
#   return {
#     store: store
#     model: model
#     models: models
#     find: find
#     materialize: materialize
#   }
# 
# 
# # For an arrayController whose content is an instance of CanModelList,
# # provide computed properties to avoid fetching content.isLoaded
# # (this is only syntaxic sugar, and a little training)
# App.ArrayModelController = Ember.ArrayController.extend({
#   isLoaded: Ember.computed ->
#     # console.log "compute isLoaded for an arrayController: ", @get('content').get('isLoaded')
#     @get('content').get('isLoaded')
#   .property('content.isLoaded')
# 
#   isError: Ember.computed ->
#     @get('content').get('isError')
#   .property('content.isError')
# })
# 
# 
# ################################################################################ 
# # Models definition
# ################################################################################ 
# App.Post = App.CanModel.extend()
# App.Post.reopenClass(makeCanModel.call(App.Post, {
#   url: {
#     findAll: "#{App.get('serviceUrl')}?json=get_recent_posts"
#     find: "#{App.get('serviceUrl')}?json=get_post&post_slug=:slug"
#   }
#   id: 'slug'
# }))
# App.Post.reopenClass({
#   materialize: (hash) ->
#     hash.categories = App.Category.models(hash.categories, true)
#     hash.author = App.Author.model(hash.author, true)
#     hash.tags = App.Tag.models(hash.tags, true)
#     return hash
# 
#   findByTag: (tag_id) ->
#     res = App.CanModelList.create()
#     findAllUrl = "#{App.get('serviceUrl')}?json=get_tag_posts&tag_slug=#{tag_id}"
# 
#     finding = $.getJSON(findAllUrl)
#     finding.done (data) =>
#       models = App.Post.models(data.posts, true)
#       tag = App.Tag.model(data.tag, true)
#       window.models = models
#       res.setProperties({
#         content: models
#         count: data.count
#         isLoaded: true
#         tag: tag
#       })
#     return res
#   
#   findByCategory: (category_id) ->
#     res = App.CanModelList.create()
#     findAllUrl = "#{App.get('serviceUrl')}?json=get_category_posts&category_slug=#{category_id}"
# 
#     finding = $.getJSON(findAllUrl)
#     finding.done (data) =>
#       models = App.Post.models(data.posts, true)
#       category = App.Category.model(data.category, true)
#       window.models = models
#       res.setProperties({
#         content: models
#         count: data.count
#         isLoaded: true
#         category: category
#       })
#     return res
# 
# })
# 
# App.Category = App.CanModel.extend()
# App.Category.reopenClass(makeCanModel.call(App.Category, {
#   plural: 'categories'
#   id: 'slug'
# }))
# App.Category.reopenClass({
#   model: (hash) -> return @_super(hash)
# })
# 
# App.Tag = App.CanModel.extend()
# App.Tag.reopenClass(makeCanModel.call(App.Tag, {
#   id: 'slug'
# }))
# 
# App.Author = App.CanModel.extend()
# App.Author.reopenClass(makeCanModel.call(App.Author))
# 
# 
# ################################################################################ 
# # Router
# ################################################################################ 
# App.Router.map ->
#   @resource('posts', ->
#     @resource('post', {path: ':post_id'})
#   )
# 
#   @resource('tags', ->
#     @resource('tag', {path: ":tag_id"})
#   )
# 
#   @resource('categories', ->
#     @resource('category', {path: ":category_id"})
#   )
# 
# App.IndexRoute = Ember.Route.extend({
#   redirect: -> @transitionTo('posts')
# })
# 
# App.PostsRoute = Ember.Route.extend({
#   model: -> App.Post.find()
# })
# 
# App.PostsIndexRoute = Ember.Route.extend({
#   model: (params) -> App.Post.find(params.post_id)
# })
# 
# App.TagsIndexRoute = Ember.Route.extend({
#   model: -> App.Tag.find()
# })
# 
# App.TagRoute = Ember.Route.extend({
#   # model: ({tag_id})-> App.Post.findByTag(tag_id)
#   # renderTemplate: (controller, model) ->
#   #   controller.set('content', App.Post.findByTag(model.get('id')))
#   #   @render()
# })
# 
# App.CategoryRoute = Ember.Route.extend({
#   model: ({category_id}) -> App.Post.findByCategory(category_id)
#   # renderTemplate: (controller, model) ->
#   #   console.log "model: ", model
#   #   console.log "looking for category with id: ", model.get('id')
#   #   controller.set('content', App.Post.findByCategory(model.get('id')))
#   #   @render()
# })
# 
# App.TagsController = Ember.ArrayController.extend()
# App.TagController = Ember.ObjectController.extend({
#   postsForTag: Ember.computed ->
#     return App.Post.findByTag(@get('model').get('id'))
#   .property('content')
# })
# 
# App.CategoryController = Ember.ObjectController.extend()
# 
# App.PostsController = Ember.ArrayController.extend()
# App.PostController = Ember.ObjectController.extend()
# 
# # App.PostPreviewController = Ember.View.extend()
# # App.TagController = App.ArrayModelController.extend()
# # App.PostsController = App.ArrayModelController.extend()
# # App.CategoryController = App.ArrayModelController.extend()
# 
# 
