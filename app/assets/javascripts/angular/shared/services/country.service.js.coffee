angular
.module 'api.services'
.factory 'Country', ['ApiResource', (ApiResource) ->
  class Country extends ApiResource
    @configure url: Routes.api_countries_path(), name: 'country', pluralName: 'countries'
]