angular
.module 'api.services'
.factory 'User', ['ApiResource', '$collection', (ApiResource, $collection) ->
  class User extends ApiResource
    @configure url: Routes.users_path(), name: 'user'
    constructor: (model) ->
      return if !model
      @id = model.id
      @name = model.name
      @company = model.company
      @filterName = ''

    @approve: (Id, approved) ->
      @$post @$url "#{Id}/approve?approved=#{approved}"

    @getAllUserExceptAdmin: (params) ->
      @get @configure, params

    @totalUsers: (params) ->
      @get "/total_user", params

    @addBudget: (params) ->
      @$post @$url "add_budget?#{$.param(params)}"

]