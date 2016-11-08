angular
.module 'api.services'
.factory 'Cost', ['ApiResource', (ApiResource) ->
  class Cost extends ApiResource
    @configure url: Routes.api_costs_path(), name: 'cost'
    @getPrice: (countryId, pricing_model) ->
      @$get @$url('get_price'),
        countryId: countryId
        pricing_model: pricing_model
]