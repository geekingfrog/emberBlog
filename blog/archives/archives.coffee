App.YearRoute = Ember.Route.extend({
  model: ({y}) ->
    console.log "year route: ", arguments
    return y
})

App.MonthRoute = Ember.Route.extend({
  model: ({m}) ->
    console.log "month route: ", arguments
    return m
})

App.ArchivesIndexController = Ember.ArrayController.extend({
  needs: 'sideMenu'
  dateNestedArray: Ember.computed ->
    tree = @get('controllers.sideMenu.dateTree')
    return [] unless tree.get('isLoaded')
    res = []
    for year, details of tree.get('tree')
      content = ({
        m: month
        c: count
        date: new Date("#{year}-#{month}")
      } for month, count of details)
      content.sort (a,b) -> b.m - a.m
      res.push {y: year, content: content}
    res.sort (a,b) -> b.y - a.y
    return res
  .property('controllers.sideMenu.dateTree.isLoaded')
})

App.YearIndexController = Ember.ObjectController.extend({
  needs: ["year", "archivesIndex"]
  monthsIndex: Ember.computed ->
    index = @get("controllers.archivesIndex.dateNestedArray")
    year = @get("controllers.year.content")
    posts = _.find(index, (el) -> el.y is year)
    return if posts then posts.content else []
  .property("controllers.archivesIndex.dateNestedArray", "controllers.year.content")
})

App.MonthController = Ember.ObjectController.extend({
  needs: 'year'

  posts: Ember.computed ->
    year = @get("controllers.year.content")
    month = @get("content")
    return App.Post.getPostsForDate({year: year, month: month})
  .property("controllers.year.content")
})

# nicely format dates with moment and a given format
Ember.Handlebars.registerBoundHelper('formatMoment', (date, options) ->
  format = options?.hash?.format
  return date if not date? or not format?
  return moment(date).format(format)
)
