angular.module('campaign.detail.app')
.controller('AdminCampaignExchangeStatsController', [
    '$scope'
    ($scope) ->

      $scope.init = (campaign_id) ->
        $scope.campaign_id = campaign_id
        $scope.current_row_number = 1

        return

      $scope.initDataGrid = () ->
        $('#campaign-exchange-table').DataTable
          processing: true
          serverSide: true
          ajax: Routes.index_campaign_exchange_stats_path($scope.campaign_id, {format: 'json'})
          autoWidth: false
          lengthMenu: [ 15, 30, 50, 75, 100 ]
          preDrawCallback: (settings) ->
            $scope.current_row_number = settings._iDisplayStart + 1
          columns: [
            {
              data: null
              orderable: false
              width: '5%'
              render: ->
                $scope.current_row_number++
            }
            {
              data: 'exchange_name'
            }
            {
              data: 'views'
            }
            {
              data: 'clicks'
            }
            {
              data: 'ctr'
            }
          ]
          order: [[1, 'asc']]
          searching: false
  ])
