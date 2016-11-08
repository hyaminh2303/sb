angular
.module 'api.services', ['rails', 'collection.services']
.factory 'ApiResource', ['RailsResource', (RailsResource) ->
  class ApiResource extends RailsResource
    @new: () ->
      @$get(@$url('new'))
]