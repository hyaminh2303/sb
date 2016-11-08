angular
.module 'api.services'
.factory 'Location', ['ApiResource', '$collection', (ApiResource, $colection) ->
  class Location extends ApiResource
    @configure url: Routes.api_campaign_locations_path(), name: 'campaign_location'
    @getByCampaign: (campaignId) ->
      @$get @$url "get_by_campaign/#{campaignId}"
    @saveByCampaign: (campaignId, locations) ->
      @$post @$url('save_by_campaign'),
        campaignId: campaignId
        locations: $colection.map locations, (location) ->
          name: location.name
          latitude: location.center.latitude
          longitude: location.center.longitude
          radius: location.radius
      ,
        rootWrapping: false

]