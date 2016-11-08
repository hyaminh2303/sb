app = angular.module 'campaign.edit.app', ['api.services', 'collection.services', 'campaign.controllers', 'ui.router', 'blockUI', 'ui.bootstrap', 'datePicker']
app.config ['$urlRouterProvider', '$stateProvider', 'blockUIConfig'
  ($urlRouterProvider, $stateProvider, blockUIConfig) ->
    blockUIConfig.message = 'Loading...';
    $urlRouterProvider.otherwise '/'
    config =
      rootName: 'campaigns_edit'
      isEdit: true
      isNew: false
      isClone: false
      saveOnStepChanged: false
      getCampaign: (Campaign, id) ->
        Campaign.get(id)

    $stateProvider.state
      abstract: true
      name: 'campaign_edit'
      url: '/'
      templateUrl: '/campaigns/steps'
      controller: 'CampaignStepsController'
      controllerAs: 'stepsCtrl'
      data: config
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
