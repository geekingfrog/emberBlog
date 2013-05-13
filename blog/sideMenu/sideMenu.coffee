App.SideMenuController = Ember.Controller.extend(
  categories: App.Category.find()
  dateTree: App.Post.getDateIndex()
  dateArray: Ember.computed ->
    tree = @get('dateTree')
    return [] unless tree.get('isLoaded')

    dateArray = []
    for year, yDetails of tree.get('tree')
      for month, count of yDetails
        dateArray.push {
          y: year
          m: month
          c: count
          date: new Date(year+"-"+month)
          human: moment(year+'-'+month, "YYYY-MM").format('MMM YYYY')
        }
    return dateArray.sort( (a,b) -> b.date.getTime() - a.date.getTime())
  .property('dateTree.isLoaded', 'dateTree.tree')

  search: (query) ->
    console.log "search with args: ", arguments
    @transitionToRoute('search',App.Post.searchForPosts(query))

)

App.SearchBarView = Ember.View.extend(
  templateName: 'searchBar'
  query: ""
  submit: (ev) ->
    ev.preventDefault()
    query = @get('query')
    if query
      @get('controller').send('search', query)
)

App.SearchRoute = Ember.Route.extend(
  model: (params) ->
    console.log "get search results for query:", params
    window.s = App.Post.searchForPosts(params.query)
    return s

  serialize: (model) ->
    return {query: model.get('query')}

)

App.SearchController = Ember.ArrayController.extend()
