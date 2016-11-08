class UserController
  @$inject: ['$scope', '$http', '$interval', '$state', '$modal', '$anchorScroll', 'User']
  constructor: (@scope, @http, @interval, @state, @modal, @anchorScroll, @User) ->
    if @scope.viewState
      userId = @scope.viewState.userId
      if @scope.isDisable
        btnApprove = angular.element( document.querySelector( '#btn-approve' ) )
        btnReject = angular.element( document.querySelector( '#btn-reject' ) )
        btnApprove.text('Approved')
        btnApprove.attr('disabled', true)
        btnReject.attr('disabled', true)
      user = @state.current.data.getUser(@User, userId).then (user) =>
        @scope.user = user
        @scope.user_name = user.name
        @scope.user_email = user.email
        @scope.user_company = user.company
    else
      @gridFilterDelay = 1000

      @scope.filterName = ''

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
        enableHorizontalScrollbar: 2
        enableVerticalScrollbar: 0
        columnDefs: [
          {
            name: ' '
            width: 10
            enableSorting: false
            cellTemplate: 'grid_cell_status_tpl.html'
          }
          {
            name: 'name'
            width: '25%'
            cellTemplate: 'grid_cell_users_name.html'
          }
          {
            width: '20%'
            name: 'email'
            cellTemplate: 'grid_cell_users_email.html'
          }
          {
            name: 'budget'
            cellTemplate: 'grid_cell_users_budget.html'
          }
          {
            name: 'company'
            cellTemplate: 'grid_cell_users_company.html'
          }
          {
            name: 'status'
            cellTemplate: 'grid_cell_users_status.html'
          }
          {
            name: 'roleName'
            width: '8%'
            cellTemplate: 'grid_cell_users_role.html'
            enableSorting: false
          }
          {
            name: 'actions'
            cellClass: 'actions'
            width: '7%'
            cellTemplate: 'grid_cell_users_action.html'
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
          return
      @getData()

  getData: =>
    @scope.isLoading = true

    params = {
      page: @scope.gridFilterOptions.pagination.pageNumber
      per: @scope.gridFilterOptions.pagination.pageSize
      sort_by: @scope.gridFilterOptions.sort.field
      order_by: @scope.gridFilterOptions.sort.order
      search_by: @scope.gridFilterOptions.filter.field
      search_term: @scope.gridFilterOptions.filter.term
    }

    @User.getAllUserExceptAdmin(params)
    .then (data) =>
      @scope.gridOptions.data = data
      @scope.enableGridFilter = data.length >= 2
      @User.totalUsers(params)
      .then (response) =>
        @scope.gridOptions.totalItems = response.totalSize
        if response.totalSize > 1
          angular.element('.grid-stats .grid .ui-grid-row:first-child').css('height', '30px')
        @interval (=>
          @scope.gridApi.selection.selectRow(@scope.gridOptions.data[0])
          return
        ), 0, 1

        @scope.isLoading = false
      return
    return

  filterByName: =>
    if @scope.filterTimeout
      @interval.cancel(@scope.filterTimeout)
    @scope.filterTimeout = @interval (=>
      @scope.gridFilterOptions.filter =
        term: @scope.filterName

      @User.filterName = @scope.filterName
      if @scope.filterName.length > 0
        @scope.$emit 'FilteringByName'
    ), 1000, 1


  approveUser: () ->
    @User.approve(@scope.viewState.userId, true).then (user) =>
      @scope.isDisable = user.approved
      if @scope.isDisable
        btnApprove = angular.element( document.querySelector( '#btn-approve' ) )
        btnReject = angular.element( document.querySelector( '#btn-reject' ) )
        btnApprove.attr('disabled', true)
        btnApprove.text('Approved')
        btnReject.attr('disabled', true)
        message = "<div class='alert alert-success alert-dismissable'><i class='fa fa-check'></i><button aria-hidden='true' class='close' data-dismiss='alert' type='button'>×</button>User has been approved</div>"
        $('.page-content.main-content').prepend(message)

  approve: (id) ->
    @User.approve(id, true).then (user) =>
      @showMessage(user)
      @getData()

  unApprove: (id) ->
    @User.approve(id, false).then (user) =>
      @showMessage(user)
      @getData()

  showMessage: (user) ->
    @scope.message =  if user.approved
                        "User #{user.name || user.email} has been approved"
                      else
                        "User #{user.name || user.email} has been unapproved"
    @scope.showMessage = true

  hideMessage: () ->
    @scope.showMessage = false

  rejectUser: () ->
    @User.approve(@scope.viewState.userId, false).then (user) =>
      console.log(user)

  openAddBudgetModal: (size, email, budget) =>
    modalInstance = @modal.open(
      templateUrl: 'add_budget_modal.html'
      controller: 'ModalInstanceCtrl'
      resolve:
        userEmail: ->
          return email;
        userBudget: ->
          return budget;
    )
    modalInstance.result.then (budget) =>
      @addBudgetToUser(email, budget)
      return

  addBudgetToUser: (email, budget) =>
    params = {
      email: email
      budget: budget
    }
    @User.addBudget(params)
    .then =>
      @getData()

  resetAgencyPassword: (userId, userEmail) =>
    swal
      title: "Are you sure you want to reset user #{userEmail} password?"
      type: "warning"
      showCancelButton: true
      confirmButtonColor: "#DD6B55"
      confirmButtonText: "Yes"
      cancelButtonText: "No"
      closeOnConfirm: true
    , (isConfirm) =>
      if isConfirm
        @User.$post(Routes.reset_password_user_path(userId)).then (result) =>
          @scope.showMessage = true
          @scope.message = "The user #{userEmail} password has been reset to: #{result.generatedPassword}"
          @anchorScroll()

angular
.module 'user.controllers', ['ui.select', 'ui.bootstrap', 'templates', 'ngSanitize']
.controller 'UserController', UserController
.config ['$httpProvider', ($httpProvider) ->
  authToken = $("meta[name=\"csrf-token\"]").attr("content")
  $httpProvider.defaults.headers.common["X-CSRF-TOKEN"] = authToken
]
.requires.push 'ui.grid', 'ui.grid.selection', 'ui.grid.pagination'