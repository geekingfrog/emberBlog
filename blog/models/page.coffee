makeModel = require('./canModel').makeCanModel
App.Page = makeModel("Page", {
  id: 'slug'
  url:
    findAll: App.get('serviceUrl')+"?json=get_page_index"
})
