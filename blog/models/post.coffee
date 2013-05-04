makeModel = require('./canModel').makeCanModel
require './category'
require './tag'
require './author'
require './comment'

App.Post = makeModel("Post", {
  url:
    findAll: "#{App.get('serviceUrl')}?json=get_recent_posts"
  id: 'slug'
  extend:
    submitComment: (comment) ->
      data = {
        post_id: @get('_id') or @get('id')
        name: comment.get('name')
        email: 'toto@totoworld.com'
        content: comment.get('content.content')
      }
      url = App.get('serviceUrl')+'?json=submit_comment'
      comment.set('isSaving', true)

      submitting = $.post(url, data)
      submitting.always -> comment.set('isSaving', false)
      submitting.then (data) ->
        console.log "comment ok, setting the id: ", data.id
        comment.set('date', data.date)
        Ember.set(comment, 'id', data.id)
        return App.Comment.model(comment.get('content'), true)
      return submitting.promise()
})
App.Post.reopenClass({
  materialize: (hash) ->
    hash.categories = App.Category.models(hash.categories, true)
    hash.author = App.Author.model(hash.author, true)
    hash.tags = App.Tag.models(hash.tags, true)
    hash.comments = App.Comment.models(hash.comments, true)
    return hash

  getDateIndex: ->
    res = Ember.Object.create({isLoaded: false})
    $.getJSON("#{App.get('serviceUrl')}?json=get_date_index").then((data) ->
      return data.tree
    ).done (tree) ->
      res.setProperties(
        isLoaded: true
        tree: tree
      )
    return res

  getPostsForDate: ({year, month}) ->
    res = App.CanModelList.create()
    formatted = "#{year}-#{month}"
    finding = $.getJSON("#{App.get('serviceUrl')}?json=get_date_posts&date=#{formatted}")

    finding.fail (xhr) ->
      res.setProperties(
        isError: true
        errorMessage: xhr.responseText
        xhr: xhr
      )
    finding.done (data) ->
      content = _.map(data.posts, (p) -> App.Post.model(p, true))
      res.setProperties(
        isLoaded: true
        content: content
      )
    return res

  getRecentPosts: (opts = {}) ->
    opts = _.extend({count: 10, page: 1}, opts)
    res = App.CanModelList.create({ pages: 0 })
    url = App.get('serviceUrl')+"?json=get_recent_posts"
    finding = $.getJSON(url, opts)
    self = this

    finding.done (data) ->
      res.setProperties
        isLoaded: true
        pages: data.pages
        total: data.count_total
        content: _.map(data.posts, (p) -> self.model(p, true))

    finding.fail (xhr) ->
      res.setProperties
        isError: true
        errorMessage: xhr.responseText
        xhr: xhr

    return res

})
