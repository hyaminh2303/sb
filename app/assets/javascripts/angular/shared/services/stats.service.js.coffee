angular
.module 'api.services'
.factory 'Statistic', ['ApiResource', '$collection', (ApiResource, $collection) ->
  class Statistic extends ApiResource
    @configure url: Routes.api_stats_path(), name: 'stats'
    constructor: ->
      @campaignId = 0
      @filterName = ''
      @filterAccount=''
      @filterCompany=''

    @campaigns: (params)->
      @$get @$url('campaigns'), params

    @totalCampaigns: (params)->
      @$get @$url('total_campaigns'), params

    @getData: (statsType, params)->
      @$get @$url(statsType), params
]