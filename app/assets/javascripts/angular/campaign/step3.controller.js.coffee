class CampaignStep3Controller
  @$inject: ['$scope', '$http', '$q', '$collection', 'uiGmapGoogleMapApi', 'Campaign', 'Location', '$state', '$timeout']

#
# Constants
#
  MIN_RADIUS: 1000
  MAX_RADIUS: 9000
  MAX_LOCATIONS: 10
  ADMIN_MAX_LOCATIONS: 100
  COUNTRY_ZOOM: 5
  ADDRESS_ZOOM: 12
  GEOCODING_URL: 'http://maps.google.com/maps/api/geocode/json'

#
# Variables
#
  currentId: 1
  validId: 1
  isEditing: false

  circleOptions:
    stroke:
      color: '#08B21F'
      weight: 2
      opacity: 1
    fill:
      color: '#08B21F'
      opacity: 0.5
    geodesic: false
    draggable: true
    clickable: true
    editable: true
    visible: true
    events: {}

  markerOptions:
    draggable: true
    modelsbyref: false

  gridOptions:
    enableVerticalScrollbar: 1
    enableHorizontalScrollbar: 0
    enableColumnMenus: false
    exporterSuppressColumns: ['_id', 'action']
    columnDefs: [
      {name: '_id', enableCellEdit: false, width: '10%'}
      {name: 'name', displayName: 'Name', width: '20%', cellTemplate: '<div class="ui-grid-cell-contents"><a href="#" ng-click="grid.appScope.goToLocation(row.entity)">{{row.entity.name}}</a></div>'}
      {name: 'center.latitude', displayName: 'Latitude', type: 'number', width: '20%', cellFilter: 'number:5'}
      {name: 'center.longitude', displayName: 'Longitude', type: 'number', width: '20%', cellFilter: 'number:5'}
      {name: 'radius', displayName: 'Radius', type: 'number', width: '17%', cellFilter: 'mToKm'}
      {name: 'action', enableCellEdit: false, displayName: '', cellTemplate: '<button class="btn btn-white btn-danger btn-sm" ng-click="grid.appScope.removeLocation(row.entity)"><i class="fa fa-times red2" /> Remove</button>', cellClass: 'text-center'}
    ]

  mapOptions:
    events: {}

  deletedLocations: []

#
# constructor
#
  constructor: (@scope, @http, @q, @collection, uiGmapGoogleMapApi, @Campaign, @Location, @state, @timeout) ->
    @scope.viewState.step = 3
    @scope.viewState.case = 'Next'
    @scope.viewState.isValid = =>
      @liveLocation().length > 0

    @scope.viewState.beforeStep3Leaving = () =>
      for location in @deletedLocations
        location._destroy = true
        @scope.campaign.locations.push location
      @deletedLocations.splice 0, @deletedLocations.length

    @scope.$watch 'isAdmin', (newValue, oldValue) =>
      @scope.isAdmin = newValue

    @scope.removeLocation = @removeLocation
    @scope.goToLocation = (location) =>
      @mapOptions.center = angular.extend {}, location.center
      @mapOptions.zoom = @ADDRESS_ZOOM

    for location in @scope.campaign.locations
      location._destroy = false if !location._destroy

    @scope.$watchCollection 'campaign.locations', () =>
      @gridOptions.data = @liveLocation()

    @circleOptions.events.radius_changed = @validateRadiusOnChanged
    @gridOptions.onRegisterApi = @attachGridEvent
    @mapOptions.events.click = @addLocationOnClicked
    @gridOptions.exporterCsvFilename = "#{@scope.campaign.name}_locationlist.csv"

    for location in @scope.campaign.locations
      location._id = @currentId++ if location._id == undefined
      if location.center == undefined
        location.center =
          latitude: location.latitude
          longitude: location.longitude

    if @state.current.data.isEdit
      @updateLocationName()
    else
      num        = @scope.campaign.locations.length
      @validId   = @scope.campaign.locations[num-1].name.charCodeAt() - 63 if num != 0
      @currentId = @scope.campaign.locations[num-1]._id + 1 if num != 0

    uiGmapGoogleMapApi.then (maps) =>
      @createButtonSearch @createSearchBox maps
      @setMapCenter()

    @timeout =>
      $viewport = $('.ui-grid-render-container')
      angular.forEach ['touchstart', 'touchmove', 'touchend','keydown', 'wheel', 'mousewheel', 'DomMouseScroll', 'MozMousePixelScroll'], (eventName) =>
        $viewport.unbind(eventName)

  limitNumberOfLocation: () =>
    if @scope.isAdmin
      @ADMIN_MAX_LOCATIONS
    else
      @MAX_LOCATIONS

#
# generate name by id
# @example getAutoName(1) -> 'A'
#
  getAutoName: (id) ->
    String.fromCharCode 64 + id
#
# validate and return valid radius
#
  validateRadius: (radius) =>
    radius = Math.round radius
    if !radius || radius < @MIN_RADIUS
      radius = @MIN_RADIUS
    else if radius > @MAX_RADIUS
      radius = @MAX_RADIUS
    radius

#
# add 1 location to the map
#
  addLocation: (lat, lng, radius, name) =>
    return if @scope.campaign.locations.length == @limitNumberOfLocation()
    radius = @validateRadius radius
    location =
      _id: @currentId
      name: name
      radius: radius
      _destroy: false
      center:
        latitude: lat
        longitude: lng
    @scope.campaign.locations.push location
    @currentId++
    @validId++

#
# remove specific location from the map
#
  removeLocation: (location) =>
    @collection.remove @scope.campaign.locations, location
    location.center = null
    @deletedLocations.push location if location.id

#
# validate radius when user drag on the map
#
  validateRadiusOnChanged: (circle, event, model) =>
    return if @isEditing
    radius = @validateRadius model.radius
    model.radius = radius
    circle.setRadius radius

#
# validate location when user edit (revert if invalid value)
#
  attachGridEvent: (gridApi) =>
    tmp = {}
    @scope.gridApi = gridApi
    gridApi.edit.on.beginCellEdit @scope, (model, colDef) =>
      tmp.latitude = model.center.latitude
      tmp.longitude = model.center.longitude
      @isEditing = true

    gridApi.edit.on.cancelCellEdit @scope, (model, colDef) =>
      @isEditing = false

    gridApi.edit.on.afterCellEdit @scope, (model, colDef) =>
      if !model.name
        model.name = @getAutoName model.id
      model.radius = @validateRadius(model.radius)
      @isEditing = false

  addLocationAndZoomIn: (lat, lng) =>
    @addLocation lat, lng, 1000, @getAutoName @validId
    @mapOptions.center =
      latitude: lat
      longitude: lng
    @mapOptions.zoom = @ADDRESS_ZOOM if @mapOptions.zoom <= @ADDRESS_ZOOM
    @scope.$applyAsync() if !@scope.$$phase

  showAlertInvalidCountry: () =>
    @showAlert "","warning" , I18n.t("campaigns.update.error.messages.location")
#
# add location when user click on map
#
  addLocationOnClicked: (mapModel, eventName, originalEventArgs) =>
    return if @scope.campaign.locations.length == @limitNumberOfLocation()
    e = originalEventArgs[0]
    lat = e.latLng.lat()
    lng = e.latLng.lng()
    @checkValidCountry lat, lng, @addLocationAndZoomIn, @showAlertInvalidCountry

  checkValidCountry: (lat, lng, callbackTrue, callbackFalse) =>
    geocoder = new google.maps.Geocoder()


    geocoder.geocode
      location:
        lat: lat
        lng: lng
    , (results, status) =>
      country = @getCountryFromGeocodeResponse results, status
      if country && country.code == @scope.campaign.countryCode
        callbackTrue(lat, lng) if callbackTrue
      else
        callbackFalse() if callbackFalse

#
# create and attach event handler for search box
#
  createSearchBox: (maps) ->
    input = document.getElementById 'searchInput'
    return false if !input
    searchBox = new maps.places.SearchBox input
    maps.event.addListener searchBox, 'places_changed', () =>
      places = searchBox.getPlaces()
      return if !places || places.length == 0
      lat = places[0].geometry.location.lat()
      lng = places[0].geometry.location.lng()
      @mapOptions.center =
        latitude: lat
        longitude: lng

      if places[0].types.length > 0 && places[0].types[0] == 'country'
        @mapOptions.zoom = @COUNTRY_ZOOM
      else
        @mapOptions.zoom = @ADDRESS_ZOOM
      @scope.$apply() if !@scope.$$phase

      if @isLocationNotExist(lat, lng)
        @checkValidCountry lat, lng, @addLocationAndZoomIn, @showAlertInvalidCountry
    input

#
# create and attach event handler for search button
#
  createButtonSearch: (input) ->
    return if !input
    button = document.getElementById 'searchButton'
    return if !button
    button.addEventListener 'click', () ->
      google.maps.event.trigger(input, 'focus')
      google.maps.event.trigger(input, 'keydown', {keyCode: 13})

#
# get location from geocode response
#
  getLocationFromGeocodeResponse: (results, status) ->
    return false if status != google.maps.GeocoderStatus.OK
    location = results[0].geometry.location
    result =
      latitude: location.lat()
      longitude: location.lng()

#
# get country from geocode response
#
  getCountryFromGeocodeResponse: (results, status) ->
    return false if status != google.maps.GeocoderStatus.OK
    for component in results[0].address_components
      if component.types[0] == 'country'
        return country =
          code: component.short_name
          name: component.long_name
    return false

#
# set map center by country code
#
  setCenterByCountry: (countryCode, fn) =>
    geocoder = new google.maps.Geocoder()
    geocoder.geocode
      address: countryCode
    , (results, status) =>
      location = @getLocationFromGeocodeResponse results, status
      fn location, @COUNTRY_ZOOM

#
# if current location in specific country, set center by current location. Otherwise set center by country
#
  setCenterByCurrentLocation: (countryCode, fn) =>
    navigator.geolocation.getCurrentPosition (position) =>
      location =
        latitude: position.coords.latitude
        longitude: position.coords.longitude
      geocoder = new google.maps.Geocoder()
      geocoder.geocode
        location:
          lat: location.latitude
          lng: location.longitude
      , (results, status) =>
        country = @getCountryFromGeocodeResponse results, status
        if country && country.code == countryCode
          fn location, @ADDRESS_ZOOM
        else
          @setCenterByCountry countryCode, fn

#
# If has locations, set by first locations else set center by current location and campaign country
#
  setMapCenter: () =>
    callback = (location, zoom) =>
      @mapOptions.center = location
      @mapOptions.zoom = zoom
      @scope.$applyAsync() if !@scope.$$phase
    if @scope.campaign.locations.length > 0
      center = angular.extend {}, @scope.campaign.locations[@scope.campaign.locations.length - 1].center
      callback center, @ADDRESS_ZOOM
    # else if navigator.geolocation
    #   @setCenterByCurrentLocation @scope.campaign.countryCode, callback
    else
      @setCenterByCountry @scope.campaign.countryCode, callback

  liveLocation: () =>
    _.where(@scope.campaign.locations, {'_destroy': false})

  readCSV: () =>
    csvfile = $("#filename_csvfile")[0].files[0]
    if !csvfile
      @showAlert "Error", "error", "No CSV file selected."
    else
      @readLatLngCSV csvfile

  isLocationNotExist: (lat, lng) =>
    center =
      latitude: lat
      longitude: lng
    if @scope.campaign.locations.length > 0
      return false if _.where(@scope.campaign.locations, {'center': center}).length
    return true

  updateLocationName: () =>
    if @liveLocation().length > 0
      @validId   = @liveLocation()[@liveLocation().length-1].name.charCodeAt() - 63
      @currentId = @liveLocation()[@liveLocation().length-1]._id + 1

  export: () =>
    @scope.gridApi.exporter.csvExport 'all', 'all'

  checkNumberOfLocation: (quan) =>
    num = quan + @scope.campaign.locations.length
    if num > @limitNumberOfLocation()
      false
    else
      true

  readLatLngCSV: (csv) =>
    reader = new FileReader()
    reader.readAsText csv
    reader.onload = (event) =>
      csvData  = event.target.result
      lines    = csvData.split(/\n/)
      if @checkNumberOfLocation(lines.length - 1)
        total    = lines.length-1
        quantity = 0
        loopNum = 0
        i = 1
        while i < lines.length
          currentline = lines[i].split(",")
          name   = currentline[0].replace(/"/g, '')
          lat    = currentline[1]
          lng    = currentline[2]
          radius = currentline[3]

          name   = @getAutoName @validId if name.trim() == ""
          radius = 1000 if radius == undefined || radius.trim() == ""

          if lat != undefined && lng != undefined && lat.trim() != "" && lng.trim() != ""
            if @isLocationNotExist(lat, lng)
              try
                geocoder = new google.maps.Geocoder()
                geocoder.geocode
                  location:
                    lat: parseFloat(lat)
                    lng: parseFloat(lng)
                , (results, status) =>
                  loopNum++
                  country = @getCountryFromGeocodeResponse results, status
                  if country && country.code == @scope.campaign.countryCode
                    quantity++
                    @addLocation parseFloat(lat), parseFloat(lng), radius, name
                    @scope.$applyAsync() if !@scope.$$phase
                  @showAlert "Success","" , quantity+" location(s) of "+total+" locations has been imported." if loopNum == total
              catch e
            else
              loopNum++
          i++
      else
        @showAlert "Warning", "warning", "Maximum can be imported is 10."

  showAlert: (title, type, message) ->
    swal
      title: title
      text: message
      type: type
      confirmButtonColor: "#DD6B55"
      confirmButtonText: "OK"


angular
.module 'campaign.controllers'
.config ['uiGmapGoogleMapApiProvider', (uiGmapGoogleMapApiProvider) ->
  uiGmapGoogleMapApiProvider.configure
    v: '3.17'
    libraries: 'places'
    key: 'AIzaSyBPhT-buPrfobD023y6-iN8TZrSnL7Vh94'
]
.filter 'mToKm', ->
  (input) ->
    input / 1000 + ' km'
.controller 'CampaignStep3Controller', CampaignStep3Controller
.requires.push 'uiGmapgoogle-maps', 'ui.grid', 'ui.grid.edit', 'ui.grid.cellNav', 'ui.grid.autoResize', 'ui.grid.selection', 'ui.grid.exporter'
