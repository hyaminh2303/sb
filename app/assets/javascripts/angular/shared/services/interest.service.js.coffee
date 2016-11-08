angular
.module 'api.services'
.factory 'Interest', ['ApiResource', (ApiResource) ->
  class Interest extends ApiResource
    @configure url: Routes.api_interests_path(), name: 'interest'
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