class Collection
  isFunction = (fn) ->
    getType = {}
    fn && getType.toString.call(fn) == '[object Function]'

  remove: (arr, param) ->
    if isFunction(param)
      i = 0
      while i < arr.length
        if fn(arr[i])
          arr.splice(i, 1)
          i--
          continue
        i++
    else
      arr.splice(array(arr).indexOf(param), 1)
  any: (arr, param) ->
    return array(arr).any(param)
  has: (arr, param) ->
    return array(arr).has(param)
  indexOf: (arr, param) ->
    return array(arr).indexOf(param)
  count: (arr, param) ->
    return array(arr).count(param)
  find: (arr, param) ->
    return array(arr).find(param)
  findLast: (arr, param) ->
    return array(arr).findLast(param)
  select: (arr, param) ->
    return array(arr).select(param).toArray()
  map: (arr, param) ->
    return array(arr).map(param).toArray()

angular
.module 'collection.services', []
.factory '$collection', () -> new Collection


