class CampaignStep1Controller
  @$inject: ['$scope', '$http', '$state', '$stateParams', 'Country', 'Category', 'Timezone', 'Cost', 'Campaign', '$filter', '$modal', '$q']
  constructor: (@scope, @http, @state, @stateParams, @Country, @Category, @Timezone, @Cost, @Campaign, @filter, @modal, @q) ->
    @scope.pricingModels = ['CPM', 'CPC']
    @campaignId = @scope.viewState.campaignId || @stateParams.id

    @scope.status =
      opened: false

    @scope.open = ($event)=>
      @scope.status.opened = true

    @scope.dateOptions =
      formatYear: 'yy'
      startingDay: 1

    @scope.viewState.step = 1
    @scope.viewState.case = 'Next'

    @scope.onCountryChange = ()=>
      @queryPrice()

    @scope.onPricingModelChange = =>
      @queryPrice()

    @scope.viewState.isValid = =>
      @scope.step1Form.$valid && @scope.campaign.budget > 0 && (@scope.campaign.budget >= @scope.minBudget || @scope.viewState.isAdmin) &&
        ((moment(@scope.campaign.endTime).startOf('day') >= moment(@scope.minEndTime).startOf('day')) || @scope.campaign.isDraft) &&
        (moment(@scope.campaign.endTime).startOf('day') >= moment(@scope.campaign.startTime).startOf('day')) &&
        (((@scope.campaign.budget <= @scope.remainingBudget && @scope.campaign.isDraft) || @scope.viewState.isAdmin) || ((!@scope.campaign.isDraft && (@scope.campaign.budget - @scope.minBudget) <= @scope.remainingBudget) || @scope.viewState.isAdmin))

    @scope.onStartDateChange = =>
      if @scope.campaign.isDraft || @scope.campaign.status == 'pending'
        @scope.minEndTime = @scope.campaign.startTime

      if moment(@scope.campaign.startTime).startOf('day') > moment(@scope.campaign.endTime).startOf('day')
        @scope.campaign.endTime = @scope.campaign.startTime
        @scope.minEndTime = @scope.campaign.startTime

    @scope.checkBudget = () =>
      @setTarget()

      # do validation
      if @scope.campaign.budget <= 0
        @showAlert I18n.t("campaigns.minimum_budget_admin")

      return if @scope.viewState.isAdmin

      if !@scope.campaign.isDraft
        @validateBudgetOnEdit()
      else
        if @scope.campaign.budget > @scope.remainingBudget
          @showAlert I18n.t("campaigns.no_sufficient")
      if @scope.campaign.budget < @scope.minBudget
        @showAlert I18n.t("campaigns.minimum_budget")

    @queryCategory()
    @queryCountry()
    @queryTimezone()

  queryCategory: () =>
    @Category.query().then (categories) =>
      @scope.categories = categories

      unless @scope.campaign.categoryId
        @scope.campaign.categoryId = categories[0].id

  queryCountry: () =>
    @Country.query().then (countries) =>
      @scope.countries = countries
      unless @campaignId
        @getLocalCountry()

  queryTimezone: () =>
    @Timezone.query().then (timezones) =>
      @scope.timezones = timezones

  setTarget: () =>
#    return unless @scope.campaign.price && @scope.campaign.pricing_model
    if @scope.campaign.pricingModel == 'CPC'
      @scope.campaign.target = Math.round @scope.campaign.budget / @scope.campaign.price
    else
      @scope.campaign.target = Math.round @scope.campaign.budget * 1000 / @scope.campaign.price

  queryPrice: () ->
    return if !@scope.campaign.countryId || !@scope.campaign.pricingModel
    @Cost
    .getPrice @scope.campaign.countryId, @scope.campaign.pricingModel
    .then (data) =>
      @scope.campaign.price = parseFloat(data.price)
      @setTarget()

  showAlert: (message) ->
    swal
      title: "Error"
      text: message
      type: "error"
      confirmButtonColor: "#DD6B55"
      confirmButtonText: "OK"

  getLocalCountry: () =>
    @http.get 'http://ipinfo.io/json'
    .then (response) =>
      arrCountry = @filter('filter')(@scope.countries, (c) ->
        c.code == response.data.country
      )
      if arrCountry.length > 0
        @scope.campaign.countryId = arrCountry[0].id
        @queryPrice()

  validateBudgetOnEdit: () =>
    if @scope.campaign.budget < @scope.minBudget
      @showAlert I18n.t("campaigns.decrease_budget")
      @scope.campaign.budget = @scope.minBudget
    if @scope.campaign.budget - @scope.minBudget > @scope.remainingBudget
      @showAlert I18n.t("campaigns.no_sufficient")

angular
.module 'campaign.controllers'
.controller 'CampaignStep1Controller', CampaignStep1Controller
.requires.push 'ui.select', 'ui.bootstrap', 'templates', 'ngSanitize'





