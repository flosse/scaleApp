# Copyright (c) 2011 Markus Kohlhase (mail@markus-kohlhase.de)

# container for global collections
globalCollections = {}

# PrivateFunction: generateId
#
# Parameters:
# (String) salt -
generateId = (salt) -> salt + (new Date()).getTime()

# PrivateClass: Collection
#
# Parameters:
# (String) cid - Collection ID
Collection = (cid) ->

  # container for objects
  collection = {}

  scaleApp.util.mixin collection, scaleApp.mvc.observable

  # identifier for the collection
  id = cid or generateId("col")

  # Function: getId
  getId = -> id

  # Function: add
  # 
  # Parameters:
  # (Object) obj     -
  # (String) id      -
  # (Boolean) silent -
  add = (obj, id, silent) ->
    oid = id or generateId("obj")
    collection[oid] = obj
    collection.notify()  if silent != true
    oid

  # Function: get
  get = (id) -> if id then collection[id] else collection

  #  Function: remove
  #  
  #  Parameters:
  #  (String) id      - 
  #  (Boolean) silent -
  remove = (id, silent) ->
    delete collection[id]
    collection.notify() if silent isnt true
  
  # Function: update
  update = (obj, silent) ->
    for i, o of collection
      if o is obj
        collection[i] = obj
        collection.notify()  if silent isnt true

  # public API
  get: get
  add: add
  remove: remove
  update: update
  getCollectionId: getId
  subscribe: collection.subscribe
  unsubscribe: collection.unsubscribe
  notify: collection.notify

# PrivateFunction: collectionPlugin
collectionPlugin = (sb, instanceId) ->

  # local container
  localCollections = {}

  # PrivateFunction: createCollection
  create = (id, global) ->
    col = new Collection(id)
    if global is true
      globalCollections[col.getCollectionId()] = col
    else
      localCollections[col.getCollectionId()] = col
    col

  # Function: getCollection
  get = (id) ->
    localCollections[id] or globalCollections[id]

  # public API
  getCollection: get
  createCollection: create

corePlugin =

  getCollection: (id) -> globalCollections[id]

  createCollection: (id) ->
    col = new Collection(id)
    globalCollections[col.getCollectionId()] = col
    col

scaleApp.registerPlugin "collection",
  sandbox: collectionPlugin
  core: corePlugin
