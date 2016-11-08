angular.module('campaign.controllers').directive 'uiSelectRequired', ->
  {
    restrict: 'A'
    require: '^ngModel'
    scope: uiSelectRequired: '='
    link: (scope, elm, attrs, ngModel) ->
      ngModel.$validators.uiSelectRequired = (modelValue, viewValue) ->
        return true unless scope.uiSelectRequired
        value = null
        if angular.isArray(modelValue)
          value = modelValue
        else if angular.isArray(viewValue)
          value = viewValue
        value.length > 0
  }
