angular
.module 'api.services'
.factory 'Os', ['ApiResource', (ApiResource) ->
  class Os extends ApiResource
    @configure url: Routes.api_operating_systems_path(), name: 'operating_system'
    constructor: (model) ->
      return if !model
#      @id = model.id
#      @name = model.name
#      @adDomain = model.adDomain
#      @startTime = model.startTime
#      @endTime = model.endTime
#      @timezone = model.timezone
#      @countryId = if model.country then model.country.id else model.countryId
#      @categoryId = if model.category then model.category.id else model.categoryId
#      @pricingModel = model.pricingModel
#      @price = model.price
#      @target = model.target
]