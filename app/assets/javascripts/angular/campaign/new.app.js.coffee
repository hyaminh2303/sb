app = angular.module 'campaign.new.app', ['api.services', 'collection.services', 'campaign.controllers', 'ui.router', 'blockUI', 'ui.bootstrap', 'datePicker']
app.config ['$urlRouterProvider', '$stateProvider', 'blockUIConfig'
  ($urlRouterProvider, $stateProvider, blockUIConfig) ->
    blockUIConfig.message = 'Loading...';
    $urlRouterProvider.otherwise '/'
    config =
      rootName: 'campaigns_new'
      saveOnStepChanged: true
      isEdit: false
      isNew: true
      isClone: false
      getCampaign: (Campaign) ->
        Campaign.new()

    $stateProvider.state
      abstract: true
      name: 'campaign_new'
      url: '/'
      templateUrl: '/campaigns/steps'
      controller: 'CampaignStepsController'
      controllerAs: 'stepsCtrl'
      data: config

    $stateProvider.state
      name: "campaign_new.step1"
      url: ''
      templateUrl: "/campaigns/step1"
      controller: "CampaignStep1Controller"
      controllerAs: "step1Ctrl"
      data: config

    $stateProvider.state
      abstract: true
      name: 'campaign_edit'
      url: '/edit/:id'
      templateUrl: '/campaigns/steps'
      controller: 'CampaignStepsController'
      controllerAs: 'stepsCtrl'
      data: config

#    $stateProvider.state
#      name: "campaign_edit.step1"
#      url: ''
#      templateUrl: "/campaigns/step1"
#      controller: "CampaignStep1Controller"
#      controllerAs: "step1Ctrl"
#      data: config

    for step in [1..4]
      $stateProvider.state
        name: "campaign_edit.step#{step}"
        url: ''
        templateUrl: "/campaigns/step#{step}"
        controller: "CampaignStep#{step}Controller"
        controllerAs: "step#{step}Ctrl"
        data: config
]
app.config ['$httpProvider', ($httpProvider) ->
  authToken = $("meta[name=\"csrf-token\"]").attr("content")
  $httpProvider.defaults.headers.common["X-CSRF-TOKEN"] = authToken
]
