#
# Controller class for Step 2.
# Allow users upload banners and input name, landing URL for each banner.
#
class CampaignStep2Controller
  #
  # Inject directives
  #

  @$inject: ['$scope', '$http', '$upload', '$timeout', '$collection', '$validator', 'Banner', 'Campaign', '$state']

  #
  # Constants
  #
  ACCEPTED_DIMENSIONS: [
    {
      width: 300
      height: 250
    }
    {
      width: 300
      height: 50
    }
    {
      width: 320
      height: 50
    }
    {
      width: 728
      height: 90
    }
  ]
  MAX_BANNERS: 50
  MAX_FILE_SIZE: 61440 # 60KB

  #
  # Constructor
  #

  constructor: (@scope, @http, @uploader, @timeout, @collection, @validator, @Banner, @Campaign,  @state) ->

    @initModels()
#    @scope.campaign = @scope.viewState.campaign
    @scope.viewState.case = 'Next'
    @scope.viewState.isValid = =>
      @hasBanners() and @scope.form.$valid

    @ACCEPTED_DIMENSIONS.push {
      width: 320
      height: 480
    } if @scope.viewState.isAdmin
  #
  # Initialize models for this Controller
  # @banners - register a collection watcher to change "Next" button state. Also watch 'form.$valid'
  # @files
  #
  initModels: ->
    @scope.viewState.step = 2

    @scope.viewState.beforeStep2Leaving = =>
      @upload @scope.campaign.banners
    @error = false

#    @scope.$watchCollection 'campaign.banners'
#    , @updateViewState
#    @scope.$watch 'form.$valid', @updateViewState

  #
  # Update "Next" button state
  #
#  updateViewState: =>
#    @scope.viewState.isValid = @readyToGo()
#    @scope.$apply() if !@scope.$$phase

  #
  # Count available banners (no _destroy flag)
  # @return [Integer]
  #
  countBanners: ->
    @collection.select @scope.campaign.banners, (banner) ->
      !banner._destroy
    .length
  #
  # Users has uploaded any banner?
  # @return [Boolean]
  #
  hasBanners: ->
    @countBanners() > 0

  #
  # Add new banners. This method will be called when users select images.
  # @param files [Array] Files are received from upload directive
  #
  addBanners: (files) ->
    for file in files
      @addBanner(file)

  #
  # Add new banner. This method will be called when users select image.
  # @param file [Object] File is received from upload directive
  #
  addBanner: (file) ->
    # Do not allow add any more banner if exceeded MAX_BANNERS
    if @countBanners() >= @MAX_BANNERS
      #TODO: notify to users
      return

    # Generate thumbnail as Base64 encoded images
    @generateThumb file, =>
      # Validate file
      if file.size > @MAX_FILE_SIZE
        @error =
          msg: 'Your image size is larger than 60KB'
#      else if !(@collection.any @ACCEPTED_DIMENSIONS, (i) ->
#        i.width == file.width and i.height == file.height
#      )
#        @error =
#          msg: 'Your image is invalid'
      else
        # Build banner
        banner = new @Banner
          name: file.name
          landingUrl: @scope.campaign.adDomain
          file: file

        # Add banner
        @scope.campaign.banners.push(banner)
        @closeAlert()
      @scope.$apply()

  #
  # Remove a banner.
  # @param banner [Banner] The banner need to be removed.
  # @param e [EventHandler] Remove button click event.
  #
  removeBanner: (banner, e) ->
    e.stopPropagation()
    if banner.id
      banner._destroy = true
#      @updateViewState()
    else
      @collection.remove(@scope.campaign.banners, banner)

  #
  # Ignore click event from upload container
  # @param e [EventHandler]
  #
  stopClickFromContainer: (e) ->
    e.stopPropagation()
    return false

  #
  # Read image data: dataUrl, width, height
  # @param file [Object] File is received from upload directive
  #
  generateThumb: (file, cb) ->
    if file != null
      if file.type.indexOf('image') > -1
        @timeout =>
          fr = new FileReader
          fr.readAsDataURL file
          fr.onload = (e) =>
            @timeout ->
              file.dataUrl = e.target.result
              img = new Image
              img.onload = ->
                file.width = img.width
                file.height = img.height
                cb()
                return
              img.src = fr.result
              return
            return
          return
    return

  #
  # Upload banners via upload service of ng-file-upload
  # @param files []
  #
  upload: (banners) ->
    generateFields = ->
      fields = {}
      for b, i in banners
        fields["#{i}"] = b

    return false if !banners or !banners.length
    @uploader.upload
      headers:
        'X-CSRF-TOKEN': $("meta[name=\"csrf-token\"]").attr("content")
      url: Routes.upload_api_banners_path()
      fileFormDataName: 'banners[][file]'
      fields: generateFields()
      formDataAppender: (fd, k, banner) =>
        fd.append 'banners[][id]', banner.id if banner.id
        fd.append 'banners[][name]', banner.name
        fd.append 'banners[][landing_url]', banner.landingUrl
        fd.append 'banners[][image]', banner.file, banner.file.name if !banner.id
        fd.append 'banners[][campaign_id]', @scope.campaign.id
        fd.append 'banners[][_destroy]', banner._destroy if banner._destroy
        return
    .progress (evt) =>
      @progressPercentage = parseInt(100.0 * evt.loaded / evt.total)
      return
    .then (response) =>
      @scope.campaign.banners = response.data.banners
      for banner in @scope.campaign.banners
        banner.landingUrl = banner.landing_url

  disableEditInfo: (banner) =>
    return false if @state.current.data.isClone 
    if @state.current.data.isEdit
      !(banner.id == undefined)
    else
      false

  #
  # Close alert and reset error to false
  #
  closeAlert: ->
    @error = false

angular
.module('campaign.controllers')
.controller('CampaignStep2Controller', CampaignStep2Controller)
.requires.push 'ngFileUpload', 'validator', 'validator.rules'