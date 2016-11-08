angular
.module 'api.services'
.factory 'Timezone', ['ApiResource', (ApiResource) ->
  class Timezone extends ApiResource
    @configure url: Routes.api_timezones_path(), name: 'timezone'
]