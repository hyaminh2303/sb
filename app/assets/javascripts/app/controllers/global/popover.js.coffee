angular.module('campaign.detail.app')
  .controller('PopoverController', [
    '$scope'
    ($scope) ->
      $scope.init = (selector) ->
        angular.element(selector).popover
          container: 'body'
          trigger: 'hover'
          placement: 'auto'
        return
  ])