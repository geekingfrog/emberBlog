require '../models/post'
require '../models/comment'


# http://stackoverflow.com/questions/8853396/logical-operator-in-a-handlebars-js-if-conditional
# this goes against the philosophy of logicless template like handlebars but I don't
# see how to put the class 'current' to the current page

App.PostsIndexRoute = Ember.Route.extend(
  model: -> App.Post.getRecentPosts()
)

App.PostsIndexController = Ember.ArrayController.extend(
  currentPage: 1

  hasPrevious: Ember.computed('currentPage', ->
    @get('currentPage') isnt 1
  ).cacheable()

  hasNext: Ember.computed('currentPage', 'content.pages', ->
    @get('currentPage') isnt @get('content.pages')
  ).cacheable()

  pageList: Ember.computed('content.pages', 'currentPage', ->
    return (for i in [0...@get('content.pages')]
      {pageNum: i+1, isCurrent: i+1 is @get('currentPage')}
    )
  ).cacheable()

  next: -> @incrementProperty('currentPage', 1)

  previous: -> @decrementProperty('currentPage', 1)

  gotoPage: (pageNum) -> @set('currentPage', pageNum)

  currentPageChanged:( ->
    @set('content', App.Post.getRecentPosts({page: @get('currentPage')}))
    offsetTop = document.getElementsByClassName('main-content')[0].offsetTop
    $('body').animate({scrollTop: offsetTop})
  ).observes('currentPage')
)

App.PostRoute = Ember.Route.extend({
  
  activate: ->
    console.log "activating route"
    @_super()
    offsetTop = document.getElementsByClassName('main-menu')[0]?.offsetTop or 0
    # doesn't work in firefox for some weird reason.
    # $('body').scrollTop(offsetTop)

    # this work however
    document.documentElement.scrollTop = offsetTop

})

App.PostController = Ember.ObjectController.extend({
  post: Ember.computed ->
    @get('content')
  .property('content')

  newComment: App.Comment.model({})

  postNewComment: ->
    console.log "posted a comment with args: ", arguments
    if @get('newComment.name') and @get('newComment.content.content')
      submitting = @get('post').submitComment(@get('newComment'))
      submitting.done =>
        comment = @get('newComment')
        @set('newComment', App.Comment.model({}))
        @get('comments').addObject comment
        return
    else
      console.log "not submitting"
})

App.PostCommentView = Ember.View.extend(
  templateName: "postComment"
  click: (ev) ->
    ev.preventDefault()
    sending = @get('controller').send('postNewComment')
)

App.PostPreviewController = Ember.ObjectController.extend({
  post: Ember.computed ->
    @get('content')
  .property('content')
})

Ember.Handlebars.registerBoundHelper('dateFromNow', (content) ->
  moment(content, "YYYY-MM-DD HH:mm:ss").fromNow()
)

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

