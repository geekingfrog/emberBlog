canModel = {} # object to be exported


# All models extend this class.
# It provides metadata about the lifecycle of the record
# To create a model, the model methods should be called:
# MyModel.model(hash) - see below how this works. The behavior is similar to canJS
#
# @attribute isLoaded: the content of the record has been
# received from the backend. If the record was created locally, isLoaded become true
# when the model succesfully save its new state with the backend
# 
# @attribute isNew: This computed property returns true if the record has an id
#
# @attribute isSaving: A request with the backend is currently taking place
#
# @attribute isError: There was an error during a request with the backend.
# In this state, the record has additional attributes:
#   errorMessage: xhr.responseText
#   xhr: xhr
# The record is also marked as not loaded.
#
# @method save: Create a record if there is no id, update it otherwise
#
# @method destroy: Issue a request to the backend to delete the records
#
# @event didLoad: triggered when the record received data from the backend
# @event didCreate: triggered when the record has successfully been saved on the backend
# @event didUpdate: same as didCreate, but only for update events
# @event didDelete: the record has been deleted on the server
# @event becameError: triggered when the record enters an error state
#
# All of this is heavily inspired by http://emberjs.com/guides/models/model-lifecycle/
App.CanModel = Ember.ObjectProxy.extend(Ember.Evented, {
  isLoaded: false
  isNew:(->!@get('content.id')).property('content.id')
  isSaving: false
  isError: false
  isDeleted: true
  save: ->
    if @get('isNew')
      @constructor.submit(this)
    else
      @constructor.update(this)
  destroy: -> @constructor.destroy(this)
})

# This is used when find() is called. It returns an array of all records with
# additional metadata such as isLoaded (all elements are loaded) and isError (at least
# one element is in error state)
App.CanModelList = Ember.ArrayProxy.extend(Ember.Evented, {
  isLoaded: false
  isError: false
})

# Create the basic functionalities
# for the model classes (store, and method to materialize models from hash)
#
# It also create methods findAll, find, create, update and delete
# 
# @param className: this is used to construct the url for the default requests.
# @param options: can provide
#   id: By default, the id of the record is expected to have the key 'id'. This setting
#     can override the default
#   url: {find, findAll, create, update, delete}, in case the default urls are not valid
#     they can be overriden
#   plural: the default plural is className+'s'
#   root: where to find the data, by default it's {plural}
makeBasicMethods = (className, options={}) ->
  type = this
  console.log "Generating model's features for #{className}"
  plural = options.plural or (className+'s').toLowerCase()
  classId = options.id or 'id'
  options.url ?= {}
  root = options.root or plural

  # all records are put in the store to avoid creating duplicates.
  # their keys is their id
  store = {}
  # array representation of the store, used by findAll
  collection = App.CanModelList.create({content: Ember.A([]) })
  
  # function to transform embedded objects into ember objects.
  # By default, it just returns the given hash
  # If one have the author embedded inside a post, he can create a record for the author
  # by overriding materialize:
  # (hash) -> hash.author = App.Author.model(hash.author, true)
  # the last true in the call to model is to set the 'isLoaded' property, since the hash
  # should comes from the backend.
  materialize = (hash) -> hash

  # function called when submitting data to the server. By default it just return the
  # content of the given record.
  # It is used to convert embedded object into a serialized form before
  # POSTing (ou PUTing) them
  # For an example, see the related unit test
  serialize = (record) -> record.get('content')

  
  # helper to put a record in error state if a request fails
  markRecordAsFailed = (record, xhr) ->
    record.setProperties
      isError: true
      isLoaded: false
      errorMessage: xhr.responseText
      xhr: xhr
    record.trigger('becameError')

  # @params hash: the hash for the new record. The content of the record will be set to
  # the materialized hash (see the function materialized).
  # If the hash has an id and a record with this id is found in the store, the method will
  # not create a new record and instead returns the one from the store
  #
  # @param loaded: by default, records are created with isLoaded set to false.
  model = (hash, loaded = false) ->
    return unless hash?
    @materialize(hash)
    # if classId isnt 'id' and hash.id?
      # Ember.warn("The given hash to create a model contains a key 'id' but the real id of the object is #{classId}. The original key id is going to be overriden")
    Ember.set(hash, 'id', hash[classId])
    record = store[hash.id]
    unless record
      record = @create({isLoaded: loaded, content: hash})
      collection.addObject record
      store[hash.id] = record
    record.set('isLoaded', loaded)
    return record

  # call model for each hash in the array
  # @param loaded: pass to model
  models = (hashArray, loaded = false) ->
    self = this
    newModels = _.map(hashArray, (hash) -> self.model(hash, loaded))
    return Ember.A(newModels)

  # decorator to filter error from the json api
  filterError = (success, error) ->
    return (data) ->
      if data.status is 'error'
        error.call(this, {responseText: data.error})
      else
        success.call(this, data)

  # This method returns an instance of CanModelList. This instance is unique for a given
  # model, so multiple call to findAll will return the same object:
  # MyModel.findAll() is MyModel.findAll() //true
  #
  # This method immediately returns the collection of all objects from the store. When
  # the backend answer, the result from the backend will override the content of the current
  # collection
  findAll = ->
    findAllUrl = options.url.findAll or
      "#{App.get('serviceUrl')}?json=get_#{className.toLowerCase()}_index"

    collection.set('isLoaded', false)
    finding = $.getJSON(findAllUrl)
    finding.done (data) =>
      models = type.models(data[root], true)
      collection.setProperties({
        content: models
        isLoaded: true
      })
      collection.trigger('didLoad')
    finding.fail (xhr) -> markRecordAsFailed(collection, xhr)

    return collection


  # This method returns an instance of the given model.
  # After the server answered, the record's content is set
  find = (id) ->
    return type.findAll() unless id?
    modelArgs = {}
    modelArgs[classId] = id
    record = @model(modelArgs)
    findUrl = options.url.find
    if findUrl
      findUrl = findUrl.replace(/:[^/&]+/i,id)
    else
      findUrl = "#{App.get('serviceUrl')}?json=get_#{className.toLowerCase()}&#{className.toLowerCase()}_#{classId}=#{id}"

    finding = $.getJSON(findUrl)
    finding.done filterError( (data) =>
      # @model(data[className.toLowerCase()], true)
      newHash = @materialize(data[className.toLowerCase()])
      Ember.set(newHash, 'id', data[className.toLowerCase()][classId])
      record.setProperties({
        isLoaded: true
        content: newHash
      })
      record.trigger('didLoad')
    , (xhr) -> markRecordAsFailed(record, xhr)
    )
    finding.fail (xhr) -> markRecordAsFailed(record, xhr)

    return record

  # called to create an object on the server
  submit = (record) ->
    return if _.isEmpty(record.get('content'))
    record.set('isSaving', true)
    submitUrl = options.url.submit or "#{App.get('serviceUrl')}/#{plural}"
    @serialize(record)
    submitting = $.post(submitUrl, @serialize(record))
    
    submitting.always -> record.set('isSaving', false)
    submitting.done (res) ->
      Ember.set(record.get('content'), classId, res[classId])
      record.set('isLoaded', true)
      record.trigger('didCreate')
    submitting.fail (xhr) -> markRecordAsFailed(record, xhr)
    return record

  # called to update a record on the server
  update = (record) ->
    Ember.assert('You cannot update a model without an id. Use create if the record is new or
specify its id if it\'s a non standard one', !record.get('isNew'))
    record.set('isSaving', true)
    updateUrl = options.url.update or
      "#{App.get('serviceUrl')}/#{plural}/#{record.get(classId)}"
    updating = $.ajax
      url: updateUrl
      type: 'PUT'
      dataType: 'json'
      data: @serialize(record)

    updating.always -> record.set('isSaving', false)
    updating.done -> record.trigger('didUpdate')
    updating.fail (xhr) -> markRecordAsFailed(record, xhr)
    return record

  destroy = (record) ->
    record.set('isSaving', true)
    deleteUrl = options.url.delete or "#{App.get('serviceUrl')}/#{plural}/#{record.get('id')}"

    deleting = $.ajax
      url: deleteUrl
      type: 'DELETE'
  
    deleting.always -> record.set('isSaving', false)
    deleting.done ->
      collection.removeObject(record)
      record.set('isDeleted', true)
      record.trigger('didDelete')
    deleting.fail (xhr) -> markRecordAsFailed(record, xhr)
    
    return record


  return {
    store: store
    model: model
    models: models
    find: find
    findAll: findAll
    update: update
    submit: submit
    destroy: destroy
    materialize: materialize
    serialize: serialize
  }

# function to create a model:
# App.MyModel = canModel.makeCanModel("MyModel")
canModel.makeCanModel = (className, options) ->
  Ember.assert('You must provide a classname', className?)
  res = App.CanModel.extend()
  res.reopenClass(makeBasicMethods.call(res, className, options))
  return res

module.exports = canModel
