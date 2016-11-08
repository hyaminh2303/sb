//= require jquery
//= require jquery_ujs
//= require js-routes
//= require i18n
//= require i18n/translations
//= require twitter/bootstrap
//= require ckeditor-jquery
//= require ckeditor/config
//= require lodash
//= require ace/ace
//= require ace/ace-elements
//= require ace/bootbox
//= require moment
//= require highcharts/highstock
//= require array/dist/array.min
//= require async/lib/async
//= require angular/angular.js
//= require angular-ui-router/release/angular-ui-router
//= require angular-rails-templates
//= require angular-sanitize/angular-sanitize.js
//= require angular-ui-select/dist/select
//= require angular-bootstrap/ui-bootstrap-tpls
//= require angular-google-maps/dist/angular-google-maps
//= require angular-ui-grid/ui-grid.min.js
//= require angular-ui-grid/ui-grid
//= require angular-block-ui/dist/angular-block-ui.min
//= require highcharts-ng/dist/highcharts-ng.min
//= require ng-file-upload/angular-file-upload-shim.min
//= require ng-file-upload/angular-file-upload.min
//= require angular-validator/dist/angular-validator.min
//= require angular-validator/dist/angular-validator-rules.min
//= require angularjs/rails/resource
//= require angular-touch/angular-touch
//= require dataTables/jquery.dataTables
//= require select2/dist/js/select2.min.js
//= require sweetalert/dist/sweetalert.min.js
//= require_tree ./angular/shared

var ready = function () {
    $(".select2-tags").select2({tags:[], separator: "'"});
};
$(document).ready(ready);
angular.module('campaign.detail.app', [])