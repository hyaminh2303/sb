#= require_tree ./controllers/campaign_group_details
#= require_tree ./controllers/campaign_os_stats
#= require_tree ./controllers/campaign_creative_stats
#= require_tree ./controllers/campaign_carrier_stats
#= require_tree ./controllers/campaign_device_stats
#= require_tree ./controllers/campaign_app_stats
#= require_tree ./controllers/campaign_location_stats
#= require_tree ./controllers/campaign_city_stats
#= require_tree ./controllers/campaign_exchange_stats
#= require_tree ./controllers/global

$(document).ready ->
# Call initDataGrid one time only
  $('#campaign-nav-tab a[href="#location"]').on('shown.bs.tab', (e) ->
    angular.element($('#location .datatable-container')).scope().initDataGrid()
    $(this).unbind('shown.bs.tab')
  )
  $('#campaign-nav-tab a[href="#city"]').on('shown.bs.tab', (e) ->
    angular.element($('#city .datatable-container')).scope().initDataGrid()
    $(this).unbind('shown.bs.tab')
  )
  $('#campaign-nav-tab a[href="#os"]').on('shown.bs.tab', (e) ->
    angular.element($('#os .datatable-container')).scope().initDataGrid()
    $(this).unbind('shown.bs.tab')
  )
  $('#campaign-nav-tab a[href="#creatives"]').on('shown.bs.tab', (e) ->
    angular.element($('#creatives .datatable-container')).scope().initDataGrid()
    $(this).unbind('shown.bs.tab')
  )
  $('#campaign-nav-tab a[href="#carrier"]').on('shown.bs.tab', (e) ->
    angular.element($('#carrier .datatable-container')).scope().initDataGrid()
    $(this).unbind('shown.bs.tab')
  )
  $('#campaign-nav-tab a[href="#application"]').on('shown.bs.tab', (e) ->
    angular.element($('#application .datatable-container')).scope().initDataGrid()
    $(this).unbind('shown.bs.tab')
  )
  $('#campaign-nav-tab a[href="#device_id"]').on('shown.bs.tab', (e) ->
    angular.element($('#device_id .datatable-container')).scope().initDataGrid()
    $(this).unbind('shown.bs.tab')
  )
  $('#campaign-nav-tab a[href="#exchange"]').on('shown.bs.tab', (e) ->
    angular.element($('#exchange .datatable-container')).scope().initDataGrid()
    $(this).unbind('shown.bs.tab')
  )
