require '../models/post'

App.PostsIndexRoute = Ember.Route.extend(
  model: -> App.Post.find()
)


App.PostController = Ember.ObjectController.extend({
  foo: 'foooo'
  dateFromNow: Ember.computed ->
    m = moment(@get('date'), "YYYY-MM-DD HH:mm:ss")
    return m.fromNow()
  .property('content.date')
})

Ember.Handlebars.registerBoundHelper('formatContent', (content) ->
  $content = $ content
  augmented = $content.map (i, el) ->
    return el unless (el.tagName is "PRE" and el.className)
    console.log "code block to format: ", el

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

  console.log "augmented: ", augmented
  res = ""
  # augmented.each (i, el) ->
  #   html = $(this).html()
  #   res += if html then html else '<br/>'
  res = $('<div>').append(augmented).html()

  return new Handlebars.SafeString(res)
  # return new Handlebars.SafeString(res.replace(/\n/,'<br />\n'))
)

