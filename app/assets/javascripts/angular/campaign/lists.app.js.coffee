app = angular.module 'campaign.lists.app', ['smart-table', 'ui.select']

app.config ['$httpProvider', ($httpProvider) ->
  authToken = $("meta[name=\"csrf-token\"]").attr("content")
  $httpProvider.defaults.headers.common["X-CSRF-TOKEN"] = authToken
]

app.controller("ListsController", ["$scope", "$http", ($scope, $http) ->
  currentState = {}
  itemsByPage  = 15
  $scope.query = {}
  USER_BIDOPTIMIZATION = 'Bid Optimization'

  $scope.$watch 'isAdmin', (newValue, oldValue) =>
      $scope.isAdmin = newValue

  $http.get('/api/categories').then (result)->
    $scope.categories = result.data

  $http.get('/types').then (result)->
    $scope.types = result.data

  $http.get('/api/countries').then (result)->
    $scope.countries = result.data

  $http.get('/users_list').then (result)->
    $scope.users = result.data.users

  $scope.refresh = (tableState)->
    currentState = tableState
    params = getTableParams(tableState)
    $http.get('/campaigns.json', params: params).then (result)->
      $scope.rows = result.data.campaigns
#      result.data.count = 0 if result.data.count < itemsByPage
      tableState.pagination.numberOfPages = Math.round(result.data.count / tableState.pagination.number)

  $scope.onSelected = () =>
    selectedRow = _.findWhere $scope.rows, {isSelected: true}

  $scope.getAction = (campaign) =>
    if $scope.isAdmin
      if campaign.status == 'paused'
        onResumed(campaign.id)
      else
        onPaused(campaign.id)
    else
      if campaign.status == 'paused'
        if isPausedByBidOptimization(campaign)
          onPaused(campaign.id)
        else
         onResumed(campaign.id)
      else
        onPaused(campaign.id)

  $scope.terminateCampaign = (campaignId) =>
    swal
      title: I18n.t('campaigns.title.terminate')
      type: "warning"
      showCancelButton: true
      confirmButtonColor: "#DD6B55"
      confirmButtonText: "Yes"
      cancelButtonText: "No"
      closeOnConfirm: false
      showLoaderOnConfirm: true
    , (isConfirm) =>
      if isConfirm
        $http.delete Routes.api_campaign_path(campaignId)
        .success (response) =>
          if typeof response.base != 'undefined' && response.base.length > 0 
            if $scope.isAdmin
              showAlert "Error...", response.base[0], "error"
            else 
              showAlert "Error...", I18n.t('campaigns.update.error.messages.update_fail'), "error"
          else
            entity.status ="paused"
            showAlert "Terminated!", I18n.t('campaigns.update.success.messages.terminated'), "success"

  $scope.deleteCampaign = (campaignId) =>
    swal
      title: I18n.t('campaigns.title.delete')
      type: "warning"
      showCancelButton: true
      confirmButtonColor: "#DD6B55"
      confirmButtonText: "Yes"
      cancelButtonText: "No"
      closeOnConfirm: false
      showLoaderOnConfirm: true
    , (isConfirm) =>
      if isConfirm
        $http.post Routes.deleteCampaign_api_campaign_path(campaignId)
        .success (response) =>
          if typeof response.base != 'undefined' && response.base.length > 0 
            if $scope.isAdmin
              showAlert "Error...", response.base[0], "error"
            else 
              showAlert "Error...", I18n.t('campaigns.update.error.messages.update_fail'), "error"
          else
            $scope.refresh(currentState)
            showAlert "Deleted!", I18n.t('campaigns.update.success.messages.deleted'), "success"

  $scope.repareData = (campaignId) =>
    swal
      title: I18n.t('campaigns.repare_data')
      type: "warning"
      showCancelButton: true
      confirmButtonColor: "#DD6B55"
      confirmButtonText: "Yes"
      cancelButtonText: "No"
      closeOnConfirm: false
      customClass: 'repare-data-alert'
      closeOnCancel: true
      showLoaderOnConfirm: true
    , (isConfirm) =>
      if isConfirm
        $http.post Routes.repare_tracking_data_api_campaign_path(campaignId)
        .success (response) =>
          showAlert "Updating!", I18n.t('campaigns.update.success.messages.updating'), "success"
          $scope.refresh(currentState)

  $scope.getButtonLabel = (campaign) =>
    if $scope.isAdmin
      if campaign.status == 'paused'
        'Resume'
      else
        'Pause'
    else
      if campaign.status == 'paused'
        if isPausedByBidOptimization(campaign)
          'Pause'
        else
         'Resume'
      else
        'Pause'

  $scope.filterCampaign = () =>
    $scope.refresh(currentState)

  $scope.reset = () =>
    $scope.query = {}
    $scope.refresh(currentState)

  $scope.getTemplate = (campaign) =>
    index = $scope.rows.indexOf(campaign)
    if index % 2 == 0
      "eventRow"
    else
      "oddRow"

  $scope.getStatus = (campaign) =>
    if isPausedByBidOptimization(campaign) && !$scope.isAdmin
      'live'
    else
      campaign.status

  isPausedByBidOptimization = (campaign) ->
    currentDate = new Date()
    campaignEndDate = new Date(campaign.end_time)
    if moment(campaignEndDate).startOf('day') >= moment(currentDate).startOf('day') && campaign.update_status_by == USER_BIDOPTIMIZATION
      true
    else
      false

  onResumed = (campaign_id) =>
    $http.post Routes.resume_api_campaign_path(campaign_id)
    .success (response) =>
      updateStatus(campaign_id, response)

  onPaused = (campaign_id) =>
    $http.post Routes.pause_api_campaign_path(campaign_id)
    .success (response) =>
      updateStatus(campaign_id, response)

  getTableParams = (tableState) ->
    { 
      name:      $scope.query.name
      category:  $scope.query.category_id
      type:      $scope.query.campaign_type
      country:   $scope.query.campaign_country
      user:      $scope.query.campaign_user
      start:     tableState.pagination.start,
      limit:     tableState.pagination.number,
      sort_by:   tableState.sort.predicate,
      sort_dir:  if tableState.sort.reverse then 'asc' else 'desc'
    }

  showAlert = (title, message, type) =>
    swal
      title: title
      text: message
      type: type
      confirmButtonColor: "#DD6B55"
      confirmButtonText: "OK"

  updateStatus = (campaign_id, result) =>
    $scope.refresh(currentState)
    if result.errors.length > 0
      if $scope.isAdmin
        showAlert "Error...", result.errors, "error"
      else
        showAlert "Error...", I18n.t('campaigns.update.error.messages.update_fail'), "error"
])
