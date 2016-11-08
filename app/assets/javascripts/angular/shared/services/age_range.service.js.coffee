angular
.module 'api.services'
.factory 'AgeRange', ['ApiResource', (ApiResource) ->
  class AgeRange extends ApiResource
    @configure url: Routes.api_age_ranges_path(), name: 'age_range'
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