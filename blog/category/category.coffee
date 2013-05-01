require '../models/category'

App.CategoryRoute = Ember.Route.extend
  model: (params) -> App.Category.findPosts(params.category_id)
