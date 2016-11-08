angular.module('campaign.detail.app')
.controller('AdminCampaignGroupStatsController', [
    '$scope'
    ($scope) ->

      $scope.init = (campaign_id, group_id) ->

        $scope.campaign_id = campaign_id
        $scope.group_id = group_id

        if group_id == -1
          $scope.ajax_path = Routes.index_campaign_details_path(campaign_id, {format: 'json'})
        else
          $scope.ajax_path = Routes.detail_campaign_group_stats_path(campaign_id, group_id, {format: 'json'})
        $scope.initDataGrid(campaign_id)
        return

      $scope.initDataGrid = (campaign_id) ->
        $('#campaign-tracking-table').DataTable
          processing: true
          serverSide: true
          ajax: $scope.ajax_path
          autoWidth: false
          lengthMenu: [ 15, 30, 50, 75, 100 ]
          columns: [
            {
              data: 'time'
              render: (data) ->
                return moment(new Date(data * 1000)).format('DD MMM YY')
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
            {
              data: 'ecpm'
            }
            {
              data: 'ecpc'
              orderable: false
            }
            {
              data: 'spend'
              orderable: false
            }
          ]
          order: [[0, 'asc']]
          searching: false
  ])