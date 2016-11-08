angular.module('campaign.detail.app')
.controller('UserCampaignCarrierStatsController', [
    '$scope'
    ($scope) ->

      $scope.init = (campaign_id) ->
        $scope.campaign_id = campaign_id
        $scope.current_row_number = 1

        return

      $scope.initDataGrid = () ->
        $('#campaign-carrier-table').DataTable
          processing: true
          serverSide: true
          pagingType: "full_numbers"
          ajax: Routes.index_campaign_carrier_stats_path($scope.campaign_id, {format: 'json'})
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
              data: 'carrier_name'
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
