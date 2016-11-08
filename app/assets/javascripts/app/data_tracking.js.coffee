#= require bootstrap-datepicker

ready = ->
  $(".datepicker").datepicker({
    autoclose: true
  })

$(document).ready ready