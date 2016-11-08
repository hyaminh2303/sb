angular
.module 'api.services'
.factory 'Gender', ['ApiResource', (ApiResource) ->
  class Gender extends ApiResource
    @configure url: Routes.api_genders_path(), name: 'gender'
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