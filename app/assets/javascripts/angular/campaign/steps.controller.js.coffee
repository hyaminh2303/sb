class CampaignStepsController
  @$inject: ['$scope', '$http', '$state', '$stateParams', '$q', 'Campaign', '$rootScope']
  constructor: (@scope, @http, @state, @stateParams, @q, @Campaign, @rootScope) ->
    @scope.campaign = {}
    @scope.minBudget = 50.0
    @scope.isEdit = @state.current.data.isEdit
    campaignId = @scope.viewState.campaignId || @stateParams.id
    if campaignId
      @Campaign.get(campaignId).then (result)=>
        @scope.campaign = result
        @scope.campaign.startTime = new Date(@scope.campaign.startTime)
        @scope.campaign.endTime = new Date(@scope.campaign.endTime)

        @scope.minBudget = @scope.campaign.budget

        if @scope.campaign.isDraft
          @scope.minStartTime = new Date()
          @scope.minEndTime = @scope.campaign.startTime
        else if @scope.campaign.status == 'pending'
          @scope.minStartTime = new Date()
          @scope.minEndTime = @scope.campaign.startTime
        else
          @scope.minStartTime = @scope.campaign.startTime
          @scope.minEndTime = @scope.campaign.endTime

    else
      campaign =
        id: @scope.viewState.campaignId
        budget: 50.0
        pricingModel: 'CPM'
        bannerTypeId: 1
        startTime: new Date()
        endTime: new Date()
        timezoneId: 11
        allowBidOptimization: true
        banners: []
        locations: []
        isDraft: true
        targetCity: false
      @scope.campaign = campaign
      @scope.minStartTime = @scope.campaign.startTime
      @scope.minEndTime = @scope.campaign.endTime
#        @goTo(1)
#    else
#      @state.go 'campaign_edit.step1'

#    @state.current.data.getCampaign(@Campaign, campaignId).then (campaign) =>
#      @scope.campaign = campaign
#      if @state.current.data.saveOnStepChanged
#        @Campaign.getCurrentStep().then (res) =>
#          @state.go "#{@state.current.data.rootName}.step#{res.step}"
#      else
#        @goTo(1)
#      if campaign.isDraft && (campaign.banners.length > 0 || campaign.target != 10000)
#        # Campaign in edit, prompt user to reset
#        @alreadyEdit()
#      @rootScope.oldBudget = @scope.campaign.budget
  isActive: (step) ->
    if @scope.viewState.step >= step then 'active' else ''

  showAlert: (message) ->
    swal
      title: "Error"
      text: message
      type: "error"
      confirmButtonColor: "#DD6B55"
      confirmButtonText: "OK"

  goTo: (step, fn) =>
    func = @scope.viewState["beforeStep#{@scope.viewState.step}Leaving"]
    func() if func

    goToStep = =>
      @state.go "campaign_edit.step#{step}", {id: @stateParams.id || @scope.campaign.id}

    if @state.current.data.saveOnStepChanged
      if fn
        @q.when fn()
        .then (data)=>
          @Campaign.saveCurrentStep(step).then(goToStep)
      else
        new @Campaign(@scope.campaign).save().then (data) =>
          @scope.campaign = data
          @scope.campaign.startTime = new Date(@scope.campaign.startTime)
          @scope.campaign.endTime = new Date(@scope.campaign.endTime)
          @Campaign.saveCurrentStep(step).then(goToStep)
        , (result) =>
          @showAlert result.data.message
    else
      goToStep()

  prev: () ->
    @scope.case = 'Next'
    if @scope.viewState.step > 1
      @goTo @scope.viewState.step - @stepNumber('prev'), @scope.viewState["onStep#{@scope.viewState.step}Leaving"]

  next: () =>
    if @scope.viewState.step < 4
      @rootScope.allowAutoFillLocation = false
      @goTo @scope.viewState.step + @stepNumber('next'), @scope.viewState["onStep#{@scope.viewState.step}Leaving"]
    else if @scope.viewState.step == 4
      finish = =>
        if @state.current.data.saveOnStepChanged || @scope.campaign.isDraft
          new @Campaign(@scope.campaign).save().then @launchCampaign
        else
          new @Campaign(@scope.campaign).save().then (res) =>
            if res.budget instanceof Array
              @scope.viewState.errorMessages = []
              @scope.viewState.errorMessages.push res.budget[0]
            else
              promises = []
              for i in [1..4]
                fn = @scope.viewState["onStep#{i}Leaving"]
                promises.push fn() if fn
              @q.all promises
              .then @editCampaign
      if @scope.campaign.targetCity
        @removeLocationBeforeLeaving().then =>
          @scope.campaign.locations = []
          finish()
      else
        finish()
  
  stepNumber: (action) =>
    ignoreStep3 = @scope.campaign.targetCity
    if ignoreStep3 && ((action == 'next' && @scope.viewState.step == 2) || (action == 'prev' && @scope.viewState.step == 4))
      return 2
    else
      return 1

  removeLocationBeforeLeaving: () =>
    @Campaign.removeLocations(@scope.campaign)

  cancelCampaign: () ->
    bootbox.confirm
      title: '<span class="orange"><i class="ace-icon fa fa-exclamation-triangle"></i> Warning</span>'
      message: I18n.t 'campaigns.new.confirmation.cancel'
      buttons:
        confirm:
          label: '<i class="ace-icon fa fa-check"></i> Yes'
          className: 'btn btn-primary btn-sm'
        cancel:
          label: '<i class="ace-icon fa fa-times"></i> No'
          className: 'btn btn-primary btn-sm'
      callback: (confirmed) =>
        return if !confirmed
        if @scope.campaign.id
          @Campaign.cancel(@scope.campaign).then () ->
            window.location = '/'
        else
          window.location = '/'
    return

  alreadyEdit: () ->
    if @state.current.data.saveOnStepChanged && !@state.current.data.isClone
      bootbox.confirm
        title: '<span class="orange"><i class="ace-icon fa fa-exclamation-triangle"></i> Warning</span>'
        message: I18n.t 'campaigns.new.confirmation.already_edit'
        buttons:
          confirm:
            label: '<i class="ace-icon fa fa-check"></i> Yes'
            className: 'btn btn-primary btn-sm'
          cancel:
            label: '<i class="ace-icon fa fa-times"></i> No'
            className: 'btn btn-primary btn-sm'
        callback: (confirmed) =>
          return if !confirmed
          @Campaign.cancel().then () ->
            window.location.replace('/campaigns/new')
    return

  launchCampaign: () =>
    @Campaign.launch(@scope.campaign).then (messages) =>
      if Object.keys(messages).length > 0
        @scope.viewState.errorMessages = []
        if @scope.viewState.isAdmin
          for key, values of messages when angular.isArray(values)
            field = I18n.t "campaigns.new.error.field.#{key}"
            @scope.viewState.errorMessages.push "#{field}: #{values[0]}"
        else
          @scope.viewState.errorMessages.push "Error: #{I18n.t("user_error")}"
      else
        # similar behavior as an HTTP redirect
        @Campaign.saveCurrentStep 1
        .then ()->
          window.location.replace('/')

  editCampaign: () =>
    @Campaign.edit(@scope.campaign).then (messages) =>
      if Object.keys(messages).length > 0
        @scope.viewState.errorMessages = []
        if @scope.viewState.isAdmin
          if messages.base[0].indexOf("Required Date Range") >= 0 
            window.location.replace('/')
          else
            for key, values of messages when angular.isArray(values)
              field = I18n.t "campaigns.new.error.field.#{key}"
              @scope.viewState.errorMessages.push "#{field}: #{values[0]}"
        else
          @scope.viewState.errorMessages.push "Error: #{I18n.t("user_error")}"
      else
        # similar behavior as an HTTP redirect
        window.location.replace('/')

# similar behavior as clicking on a link
# window.location.href = '/'

angular
.module 'campaign.controllers', []
.controller 'CampaignStepsController', CampaignStepsController