app = angular.module "new.user.app", ['ui.select', 'ui.bootstrap', 'api.services', 'templates']

app.config ['$httpProvider', ($httpProvider) ->
  authToken = $("meta[name=\"csrf-token\"]").attr("content")
  $httpProvider.defaults.headers.common["X-CSRF-TOKEN"] = authToken
]

app.controller("newUserController", ["$scope","$http", "User", ($scope, $http, User) ->

  $scope.userErrorMessages = []
  $scope.user = {}
  $scope.user.role = []
  $http.get(Routes.roles_path(format: 'json')).then (result) =>
    $scope.roles = result.data.roles
    $scope.user.role = $scope.roles[1].id

  $scope.$watch 'user.id', (newValue, oldValue) =>
    $scope.isEdit = $scope.user.id?
    if $scope.isEdit
      $scope.buttonText = 'Update'
      User.$get(Routes.edit_user_path($scope.user.id)).then (result) =>
        $scope.user = result
    else
      $scope.buttonText = 'Create'

  @createUser = () =>
    User.$post(Routes.users_path(format: 'json'), $scope.user).then () =>
      window.location = Routes.users_path()

    , (respond) =>
      $scope.userErrorMessages = respond.data.message
  
  @editUser = () =>
    User.$put(Routes.user_path($scope.user.id, format: 'json'), $scope.user).then () =>
      window.location = Routes.users_path()
    , (respond) =>
      $scope.userErrorMessages = respond.data.message

  @cancel = () =>
    window.location = Routes.users_path()
    
])