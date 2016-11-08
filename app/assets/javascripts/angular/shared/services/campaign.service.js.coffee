angular
.module 'api.services'
.factory 'Campaign', ['ApiResource', '$collection', (ApiResource, $collection) ->
  class Campaign extends ApiResource
    @configure url: Routes.api_campaigns_path(), name: 'campaign'
    constructor: (model) ->
      return if !model
      @id = model.id
      @name = model.name
      @adDomain = model.adDomain
      @startTime = moment(model.startTime).format('YYYY-MM-DD')
      @endTime = moment(model.endTime).format('YYYY-MM-DD')
      @bannerTypeId = model.bannerTypeId
      @timezoneId = model.timezoneId
      @countryId = model.countryId
      @categoryId = model.categoryId
      @pricingModel = model.pricingModel
      @price = model.price
      @target = model.target
      @budget = model.budget
      @allowBidOptimization = model.allowBidOptimization
      @targetCity = model.targetCity
      @cityIds = model.cityIds
      @operatingSystemIds = model.operatingSystemIds
      @targetCampaignIds = model.targetCampaignIds
      @citiesRadius = model.citiesRadius

#      @banners = $collection.map model.banners, (banner) ->
#        result =
#          id: banner.id
#          name: banner.name
#          landing_url: banner.landingUrl
#          campaign_id: banner.campaign_id
#        result._destroy = banner._destroy if banner._detroy
#        if !banner.id && banner.file
#          result.image =
#            file: banner.file
#            fileName: banner.file.name
      @genderIds = model.genderIds
      @categoryIds = model.categoryIds

      @campaignLocations = model.locations || []
      for location in @campaignLocations
        if location.center
          location.latitude = location.center.latitude
          location.longitude = location.center.longitude

    @getCurrentStep: () ->
      @$get @$url 'get_current_step'

    @saveCurrentStep: (step) ->
      @$post @$url('save_current_step'),
        step: step
      , rootWrapping: false
    @launch: (campaign) ->
      @$put @$url("#{campaign.id}/launch")

    @edit: (campaign) ->
      @$post @$url("#{campaign.id}/edit")

    @cancel: (campaign) ->
      @$put @$url("#{campaign.id}/cancel")

    @getBudget: (campaign) ->
      @$get @$url("#{campaign.id}/get_budget"),
        pricing_model: campaign.pricingModel
        target: campaign.target
        price: campaign.price

    @removeLocations: (campaign) =>
      @$delete Routes.remove_campaign_locations_api_campaign_path(campaign.id)
    
    @pastCampaigns: (cityIds, countryId) =>
      @$get Routes.past_api_campaigns_path(city_ids: cityIds, country_id: countryId)

]