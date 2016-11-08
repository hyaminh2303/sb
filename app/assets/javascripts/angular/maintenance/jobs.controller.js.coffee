class MaintenanceJobsController
  @$inject: ['$scope', '$http', '$interval']
  constructor: (@scope, @http, @interval) ->
    @http.get Routes.maintenance_get_schedule_frequency_path()
    .success (data) =>
      @schedule_frequency = data.schedule_frequency

    @updateWorkers()
    @stop = @interval () =>
      @updateWorkers()
    , 3000

  onSave: () ->
    @http.post Routes.maintenance_save_schedule_frequency_path(), schedule_frequency: @schedule_frequency

  updateWorkers: () ->
    @http.get Routes.maintenance_running_jobs_path()
    .success (data) =>
      @workers = data.workers
      @lastRun = if data.workers.length == 0 then "Last run: #{data.last_run}" else ''

  runDailyTrackingWorker: () ->
    @http.post Routes.maintenance_run_daily_tracking_worker_path()

  updateExchange: () ->
    @showAlert "Success", "success", "The AdExchanges will be updated ASAP!",
    @http.get Routes.update_exchange_path()   

  showAlert: (title, type, message) ->
    swal
      title: title
      text: message
      type: type
      confirmButtonColor: "#DD6B55"
      confirmButtonText: "OK"

angular
.module 'maintenance.controllers', ['ui.select', 'ui.bootstrap', 'templates', 'ngSanitize']
.controller 'MaintenanceJobsController', MaintenanceJobsController
