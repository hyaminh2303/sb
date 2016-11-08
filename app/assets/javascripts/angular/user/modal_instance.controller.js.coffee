class ModalInstanceCtrl
  @$inject: ['$scope', '$modalInstance', 'userEmail', 'userBudget']
  constructor: (@scope, @modalInstance, @userEmail, @userBudget) ->
    @scope.userEmail = @userEmail
    @scope.userCurrentBudget = @userBudget
    @scope.ok = =>
      @modalInstance.close(@scope.userBudget)
      return

    @scope.cancel = =>
      @modalInstance.dismiss 'cancel'
      return
angular
.module 'user.controllers'
.controller 'ModalInstanceCtrl', ModalInstanceCtrl