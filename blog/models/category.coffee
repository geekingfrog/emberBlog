makeModel = require('./canModel').makeCanModel
# require './post' #circular dependency here :/

App.Category = makeModel("Category", {
  plural: 'categories'
  id: 'slug'
})

type = App.Category
App.Category.reopenClass({
  findPosts: (id) ->
    return App.Category.findAll() unless id?
    url = "#{App.get('serviceUrl')}?json=get_category_posts&category_slug=#{id}"
    record = type.model({slug: id})
    finding = $.getJSON(url)
    success = (data) ->
      posts = App.Post.models(data.posts, true)
      record.setProperties(
        isLoaded: true
        content:
          posts: posts
          post_count: data.category.post_count
          slug: data.category.slug
          description: data.category.description
          title: data.category.title
          id: data.category.slug
      )
      record.trigger 'didLoad'

    fail = ({error}) ->
      record.setProperties(
        isLoaded: false
        isError: true
        errorMessage: error
      )
      record.trigger 'becameError'

    filterError = (ok, fail) ->
      return (data) ->
        if data.status is 'error'
          fail.call(this, data)
        else
          ok.call(this, data)

    finding.done filterError(success, fail)

    return record

})
