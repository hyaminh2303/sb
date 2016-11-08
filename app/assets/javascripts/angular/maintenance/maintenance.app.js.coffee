app = angular.module 'maintenance.app', ['api.services', 'collection.services', 'maintenance.controllers', 'ui.router']
app.config ['$urlRouterProvider', '$stateProvider',
  ($urlRouterProvider, $stateProvider) ->
    $urlRouterProvider.otherwise '/'
    $stateProvider
    .state 'jobs',
      url: '/'
      templateUrl: '/maintenance/jobs'
      controller: 'MaintenanceJobsController'
      controllerAs: 'jobsCtrl'
]
