require '../models/category'

App.CategoryRoute = Ember.Route.extend
  model: (params) ->
    console.log "get posts for category with params: ", params
    App.Category.findPosts(params.category_id)

  setupController: (controller, model) ->
    console.log "setup controller with model: ", model

    # This controller can be accessed by a linkto with a category supplied
    # In this case, the category does not have the associated posts loaded
    # and we need to create this object.
    if model.get('isLoaded')
      model = App.Category.findPosts(model.get('slug'))
    controller.set('content', model)

App.CategoryController = Ember.ObjectController.extend()
