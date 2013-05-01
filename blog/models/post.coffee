makeModel = require('./canModel').makeCanModel
require './category'
require './tag'
require './author'

App.Post = makeModel("Post", {
  url:
    findAll: "#{App.get('serviceUrl')}?json=get_recent_posts"
  id: 'slug'
})
App.Post.reopenClass({
  materialize: (hash) ->
    hash.categories = App.Category.models(hash.categories, true)
    hash.author = App.Author.model(hash.author, true)
    hash.tags = App.Tag.models(hash.tags, true)
    return hash
})
