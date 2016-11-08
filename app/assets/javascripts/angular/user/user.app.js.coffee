app = angular.module 'user.app', ['api.services', 'collection.services', 'templates', 'user.controllers', 'ui.router', 'ui.bootstrap']
app.config ['$urlRouterProvider', '$stateProvider'
  ($urlRouterProvider, $stateProvider) ->
    $urlRouterProvider.otherwise '/'
    config =
      rootName: 'user'
      getUser: (User, id) ->
        User.get(id)

    $stateProvider.state
      name: config.rootName
      url: '/'
      controller: 'UserController'
      controllerAs: 'userCtrl'
      data: config
] 
app.config ['$httpProvider', ($httpProvider) ->
  authToken = $("meta[name=\"csrf-token\"]").attr("content")
  $httpProvider.defaults.headers.common["X-CSRF-TOKEN"] = authToken
]
