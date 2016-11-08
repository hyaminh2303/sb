class CampaignStep4Controller
  @$inject: ['$scope', '$collection', '$state', 'Campaign', 'AgeRange', 'Interest', 'Os', 'Gender', 'City', 'Category']
  constructor: (@scope, @collection, @state, @Campaign, @AgeRange, @Interest, @Os, @Gender, @City, @Category) ->
    @scope.viewState.errorMessages = false
    @scope.viewState.onLeave = @onLeave
    @scope.viewState.isValid = =>
      !@scope.step4Form.$invalid

    if @state.current.data.isNew 
      @scope.viewState.case = 'Launch Campaign'
    else
      if @state.current.data.isClone
        @scope.viewState.case = 'Clone Campaign'
      else
        @scope.viewState.case = 'Update Campaign'

    @scope.viewState.step = 4
    @model = {}
    @Os.query().then (operatingSystems) =>
      @scope.operatingSystems = operatingSystems
    @City.query(countryId: @scope.campaign.countryId).then (respond) =>
      @scope.cities = respond.cities
    @Gender.query().then (genders) =>
      @scope.genders = genders

    @Category.getParents().then (categories) =>
      @scope.categories = categories

    @scope.toggleAppCategory = @scope.campaign.categoryIds.length > 0
    @scope.refreshCategories = =>
      @scope.toggleGender = false
      @scope.campaign.categoryIds = []

    @scope.toggleGender = @scope.campaign.genderIds.length > 0
    @scope.refreshGenders = =>
      @scope.toggleAppCategory = false
      @scope.campaign.genderIds = []

    @scope.toggleDevicesOS = @scope.campaign.operatingSystemIds.length > 0
    @scope.refreshDevicesOs = =>
      @scope.campaign.operatingSystemIds = []

    @scope.togglePastCampaigns = @scope.campaign.targetCampaignIds.length > 0
    @scope.refreshPastCampaign = =>
      @scope.campaign.targetCampaignIds = []

    @loadCampaigns()

  loadCampaigns: (cityIds) =>
    @Campaign.pastCampaigns(cityIds, @scope.campaign.countryId).then (campaigns) =>
      @scope.campaigns = campaigns

  onLeave: () =>
    new @Campaign(@scope.campaign).save()

angular
.module 'campaign.controllers'
.controller 'CampaignStep4Controller', CampaignStep4Controller
