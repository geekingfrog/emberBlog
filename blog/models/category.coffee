makeModel = require('./canModel').makeCanModel

App.Category = makeModel("Category", {
  plural: 'categories'
  id: 'slug'
})
