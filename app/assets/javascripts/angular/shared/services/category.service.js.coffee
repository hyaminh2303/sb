angular
.module 'api.services'
.factory 'Category', ['ApiResource', (ApiResource) ->
  class Category extends ApiResource
    @configure url: Routes.api_categories_path(), name: 'category', pluralName: 'categories'
    constructor: (model) ->
      return if !model

    @getParents:() =>
      @$get Routes.parents_api_categories_path()
]