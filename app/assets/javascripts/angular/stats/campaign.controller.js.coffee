class CampaignStatsController
  @$inject: ['$scope', '$http', '$interval', 'uiGridConstants', 'Statistic', '$rootScope', '$timeout']
  constructor: (@scope, @http, @interval, uiGridConstants, @Statistic, @rootScope, @timeout) ->

    @gridFilterDelay = 1000
    @scope.filterName = ''
    @scope.filterCompany = ''
    @Statistic.filterCompany = @scope.filterCompany = @rootScope.searchByCompany
    @scope.users = []
    @scope.companies = []

    @scope.gridFilterOptions =
      filter:
        field: 'name'
        term: null
      sort:
        field: 'name'
        order: 'ASC'
      pagination:
        pageNumber: 1
        pageSize: 10

    @scope.$watchCollection 'dateFilterOptions', (oldValue, newValue)=>
      if oldValue != newValue
        @scope.$emit('ClearStats')
        @getData()

    @scope.$watchCollection 'gridFilterOptions', (oldValue, newValue)=>
      if oldValue != newValue
        @getData()

    @scope.enableGridFilter = true
    @scope.gridOptions =
      rowHeight: 50
      enableRowSelection: true
      enableRowHeaderSelection: false
      noUnselect: true
      multiSelect: false
      enableGridMenu: false
      enableColumnMenus: false
      paginationPageSize: 10
      useExternalPagination: true
      useExternalSorting: true
      rowTemplate: 'grid_row_tpl.html'
      enableHorizontalScrollbar: 0
      enableVerticalScrollbar: 0
      minRowsToShow: 11
      columnDefs: [
        {
          name: ' '
          width: 10
          enableSorting: false
          cellTemplate: 'grid_cell_status_tpl.html'
        }
        {
          name: 'name'
          width: '40%'
          cellTemplate: 'grid_cell_name_tpl.html'
        }
        {
          name: 'company'
          width: '15%'
          enableSorting: false
          cellTemplate: 'grid_cell_account_tpl.html'
        }
        {
          name: 'views'
          cellTemplate: 'grid_cell_views_tpl.html'
        }
        {
          name: 'clicks'
          cellTemplate: 'grid_cell_clicks_tpl.html'
        }
        {
          name: 'ctr'
          displayName: 'CTR'
          cellTemplate: 'grid_cell_ctr_tpl.html'
          enableSorting: false
        }
        {
          name: 'budgetSpent'
          cellTemplate: 'grid_cell_budget_spent_tpl.html'
          enableSorting: false
        }
        {
          name: 'actions'
          cellClass: 'actions'
          cellTemplate: 'grid_cell_actions_tpl.html'
          enableSorting: false
        }
      ]
      onRegisterApi: (gridApi) =>
        @scope.gridApi = gridApi
        @scope.gridApi.core.on.sortChanged @scope, (grid, sortColumns) =>
          if @scope.enableGridFilter
            if sortColumns.length == 0
              @scope.gridFilterOptions.sort = {field: null, order: 'ASC'}
            else
              @scope.gridFilterOptions.sort = {field: sortColumns[0].name, order: sortColumns[0].sort.direction}
          return
        @scope.gridApi.pagination.on.paginationChanged @scope, (newPage, pageSize) =>
          @scope.gridFilterOptions.pagination = {pageNumber: newPage, pageSize: pageSize}
          return
        @scope.gridApi.selection.on.rowSelectionChanged @scope, (row) =>
          stats =
            views: row.entity['views']
            clicks: row.entity['clicks']
            budget: row.entity['budgetSpent']
          @scope.$emit('SetStats', stats)
          @Statistic.campaignId = row.entity['id']
          @rootScope.statsType = 'views'
          @rootScope.$emit('LoadStatsChart')
          return
        return

    @getCompanies() if @scope.user.isAdmin
    @getData()

    @timeout =>
      $viewport = $('.ui-grid-render-container')
      angular.forEach ['touchstart', 'touchmove', 'touchend','keydown', 'wheel', 'mousewheel', 'DomMouseScroll', 'MozMousePixelScroll'], (eventName) =>
        $viewport.unbind(eventName)
  getData: =>
    @scope.isLoading = true

    params = {
      page: @scope.gridFilterOptions.pagination.pageNumber
      per: @scope.gridFilterOptions.pagination.pageSize
      sort_by: @scope.gridFilterOptions.sort.field
      order_by: @scope.gridFilterOptions.sort.order
      search_by: @scope.gridFilterOptions.filter.field
      search_term: @scope.gridFilterOptions.filter.term
      start_date: @scope.dateFilterOptions.startDate
      end_date: @scope.dateFilterOptions.endDate
      company: @scope.filterCompany
    }

    @Statistic.campaigns(params)
    .then (data) =>
      # fill in remaining budget in top menu
      @scope.gridOptions.data = data
      @scope.enableGridFilter = data.length >= 2
      @Statistic.totalCampaigns(params)
      .then (response) =>
        @scope.gridOptions.totalItems = response.totalSize
        @rootScope.totalCampaigns = response.totalSize
        if response.totalSize > 1
          angular.element('.grid-stats .grid .ui-grid-row:first-child').css({"height": "30px", "font-weight: bolder", "cursor": "default", "pointer-events":"none", "color": "#000000"})
          angular.element('.grid-stats .grid .ui-grid-cell:first-child').css({"color": "transparent"})
        else if response.totalSize == 0
          @resetStats()
        else if response.totalSize == 1
          angular.element('.grid-stats .grid .ui-grid-row:first-child').css({"pointer-events":"auto"})

        @interval (=>
          @scope.gridApi.selection.selectRow(@scope.gridOptions.data[0])
          return
        ), 0, 1

        @scope.isLoading = false
      return
    return

  resetStats: ->
    @scope.$emit('ClearStats')
    @Statistic.campaignId = 0
    @rootScope.statsType = 'views'
    @rootScope.$emit('LoadStatsChart')

  filterByName: =>
    if @scope.filterTimeout
      @interval.cancel(@scope.filterTimeout)
    @scope.filterTimeout = @interval (=>
      @scope.gridFilterOptions.filter =
        field: 'name',
        term: @scope.filterName
      @Statistic.filterName = @scope.filterName
    ), 1000, 1

  filterByCompany: =>
    if @scope.filterTimeout
      @interval.cancel(@scope.filterTimeout)
    @scope.filterTimeout = @interval (=>
      @Statistic.filterCompany = @scope.filterCompany
      @getData()
    ), 1000, 1

  checkAdmin: =>
    if @scope.user.isAdmin 
      false
    else
      true

  repareData: (entity) =>
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
        @http.post Routes.repare_tracking_data_api_campaign_path(entity.id)
        .success (response) =>
          @showAlert "Updating!", I18n.t('campaigns.update.success.messages.updating'), "success"
          @getData()

  refreshData: =>
    @getData()
  
  pause: (entity) ->
    @http.post Routes.pause_api_campaign_path(entity.id)
    .success (response) =>
      @onPauseResumeSuccess entity, response

  resume: (entity) ->
    @http.post Routes.resume_api_campaign_path(entity.id)
    .success (response) =>
      @onPauseResumeSuccess entity, response

  deleteCampaign: (entity) =>
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
        @http.post Routes.deleteCampaign_api_campaign_path(entity.id)
        .success (response) =>
          if typeof response.base != 'undefined' && response.base.length > 0 
            if @scope.user.isAdmin
              @showAlert "Error...", response.base[0], "error"
            else 
              @showAlert "Error...", I18n.t('campaigns.update.error.messages.update_fail'), "error"
          else
            @refreshData()
            @showAlert "Deleted!", I18n.t('campaigns.update.success.messages.deleted'), "success"

  onPauseResumeSuccess: (entity, res) =>
    if res.errors.length > 0
      if @scope.user.isAdmin
        @showAlert "Error...", res.errors, "error"
      else
        @showAlert "Error...", I18n.t('campaigns.update.error.messages.update_fail'), "error"
    else
      @refreshData()

  terminate: (entity) =>
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
        @http.delete Routes.api_campaign_path(entity.id)
        .success (response) =>
          if typeof response.base != 'undefined' && response.base.length > 0 
            if @scope.user.isAdmin
              @showAlert "Error...", response.base[0], "error"
            else 
              @showAlert "Error...", I18n.t('campaigns.update.error.messages.update_fail'), "error"
          else
            @refreshData()
            entity.status ="paused"
            @showAlert "Terminated!", I18n.t('campaigns.update.success.messages.terminated'), "success"

  getApprovedUsers: ->
    @http.get Routes.approved_users_path({format: 'json'})
    .success (response) =>
      response.users.unshift({id: 0, name: 'All'})
      @scope.users = response.users

  getCompanies: ->
    @http.get Routes.api_companies_path()
    .success (response) =>
      @scope.companies = response.companies

  getStatus: (campaign) ->
    if @isPausedByBidOptimization(campaign) && !@scope.user.isAdmin 
      'live'
    else
      campaign.status

  getAction: (campaign) ->
    if @scope.user.isAdmin
      if campaign.status == 'paused'
        @resume(campaign)
      else
        @pause(campaign)
    else
      if campaign.status == 'paused'
        if @isPausedByBidOptimization(campaign)
          @pause(campaign)
        else
         @resume(campaign)
      else
        @pause(campaign)

  getLabel: (campaign) ->
    if @scope.user.isAdmin
      if campaign.status == 'paused'
        'Resume'
      else
        'Pause'
    else
      if campaign.status == 'paused'
        if @isPausedByBidOptimization(campaign)
          'Pause'
        else
         'Resume'
      else
        'Pause'

  isPausedByBidOptimization: (campaign) ->
    USER_BIDOPTIMIZATION = 'Bid Optimization'
    currentDate = new Date()
    campaignEndDate = new Date(campaign.campaignEndTime)
    if moment(campaignEndDate).startOf('day') >= moment(currentDate).startOf('day') && campaign.updatedStatusBy == USER_BIDOPTIMIZATION
      true
    else
      false

  showAlert: (title, message, type) =>
    swal
      title: title
      text: message
      type: type
      confirmButtonColor: "#DD6B55"
      confirmButtonText: "OK"

angular
.module('stats.app')
.controller('CampaignStatsController', CampaignStatsController)
.config ['$httpProvider', ($httpProvider) ->
  authToken = $("meta[name=\"csrf-token\"]").attr("content")
  $httpProvider.defaults.headers.common["X-CSRF-TOKEN"] = authToken
]
.requires.push 'ui.grid', 'ui.grid.selection', 'ui.grid.pagination'
