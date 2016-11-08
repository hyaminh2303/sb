angular
.module 'api.services'
.factory 'City', ['ApiResource', (ApiResource) ->
  class City extends ApiResource
    @configure url: Routes.api_cities_path()
    constructor: (model) ->
      return if !model
]