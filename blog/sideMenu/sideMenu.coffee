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
)
