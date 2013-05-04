# require all templates compiled with ember_templates
require './templates'

window.App = Ember.Application.create({
  serviceUrl: "http://geekingfrog.com"
})

require './posts/post'
require './pages/pages'
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

  @resource('page', {path: 'pages/:page_id'})

  @route("fourOhFour", {path: "*:"})

App.IndexRoute = Ember.Route.extend
  redirect: -> @transitionTo 'posts'

App.ApplicationController = Ember.Controller.extend(
  pages: App.Page.find()
)

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

