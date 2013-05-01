require '../models/post'

App.PostsIndexRoute = Ember.Route.extend(
  model: -> App.Post.find()
)

App.PostRoute = Ember.Route.extend({
  model: (params) ->
    console.log "fetch model with params:", params
    App.Post.find(params.post_id)
  setupController: (controller, model) ->
    controller.set('content', model)
})

App.PostController = Ember.ObjectController.extend({
  post: Ember.computed ->
    @get('content')
  .property('content')
})

App.PostPreviewController = Ember.ObjectController.extend({
  post: Ember.computed ->
    @get('content')
  .property('content')

  dateFromNow: Ember.computed ->
    m = moment(@get('date'), "YYYY-MM-DD HH:mm:ss")
    return m.fromNow()
  .property('content.date')
})

Ember.Handlebars.registerBoundHelper('formatContent', (content) ->
  $content = $ content
  augmented = $content.map (i, el) ->
    return el unless (el.tagName is "PRE" and el.className)

    # syntax highlighter mark the language as class='brush: xxx;'
    match = el.className.match(/brush:\s*([^;]*)/i)
    language = match[1] if match.length
    language = 'javascript' if language is 'jscript'

    newEl = $('<pre>')
    newEl.addClass(language) if language
    code = $('<code>').addClass(language).append($(el).html())
    newEl.append code

    hljs.highlightBlock(code[0])
    return newEl[0]

  res = $('<div>').append(augmented).html()

  return new Handlebars.SafeString(res)
)

