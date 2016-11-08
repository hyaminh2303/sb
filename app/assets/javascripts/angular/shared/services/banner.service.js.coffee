angular
.module 'api.services'
.factory 'Banner', ['ApiResource', (ApiResource) ->
  class Banner extends ApiResource
    @configure url: Routes.api_banners_path(), name: 'banner'
    constructor: (model) ->
      return if !model
      @id = model.id
      @name = model.name
      @landingUrl = model.landingUrl
      @file = model.file

    @getUploadedBanners: =>
      @$get @$url('uploaded')

]