class ModalNotificationCtrl
  @$inject: ['$scope', '$modalInstance', 'message']
  constructor: (@scope, @modalInstance, @message) ->
    @scope.message = @message
    @scope.ok = =>
      @modalInstance.close()
      return

    @scope.cancel = =>
      @modalInstance.dismiss 'cancel'
      return
angular
.module 'campaign.controllers'
.controller 'ModalNotificationCtrl', ModalNotificationCtrl