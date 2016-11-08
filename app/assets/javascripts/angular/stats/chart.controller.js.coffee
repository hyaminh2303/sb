class StatsChartController
  @$inject: ['$scope', '$http', 'Statistic', '$rootScope']
  constructor: (@scope, @http, @Statistic, @rootScope) ->
    @scope.isEmptyChart = false
    Highcharts.setOptions global:
      useUTC: false
    @scope.chartOptions =
      options:
        chart:
          type: 'line'
          events:
            load: ()->
              this.container.onclick = null
              return
        scrollbar:
          enabled: false
        yAxis:
          min: 0,
          minRange: 1,
          allowDecimals: false
        xAxis:
          type: "datetime"
          dateTimeLabelFormats:
            second: "%H:%M:%S"
            minute: "%H:%M"
            hour: "%H:%M"
            day: "%e %b"
            month: "%e %b"
            year: "%b"
           minTickInterval: 2 * 24 * 3600 * 1000

        navigator:
          enabled: false
          height: 30
        rangeSelector:
          enabled: false
        
      title:
        text: ''
      size:
        height: 300

      series: [
        name: 'Impressions'
        tooltip:
          useHTML: true
          valuePrefix: ""
          formatter: ->
            "<p>" + @points[0].series.chart.tooltip.valuePrefix + @y.toLocaleString() + "</p><p>" + @points[0].series.name + "</p><p>" + (new Date(@x)).toString("d MMM") + "</p>" 
      ]

    @rootScope.$on 'LoadStatsChart', ()=>
      @loadStatsChart()
      @loadStatsChart()

  loadStatsChart: ()=>

    @scope.isLoading = true

    statsType = @rootScope.statsType

    params =
      start_date: @scope.dateFilterOptions.startDate
      end_date: @scope.dateFilterOptions.endDate
      campaign_id: @Statistic.campaignId
      search_term: @Statistic.filterName
      account: @Statistic.filterAccount
      company: @Statistic.filterCompany

    @Statistic.getData(statsType, params)
    .then (response)=>
      data = []
      response.category.forEach (e,i)->
        data.push([e, response.data[i]])
      chart = @scope.chartOptions.getHighcharts()
      chart.series[0].setData(data)
      chart.series[0].name = @CHART_TITLES[statsType]
      if statsType == 'budget_spent'
        chart.tooltip.valuePrefix = '$'
        @scope.chartOptions.options.yAxis.allowDecimals = true
      else
        chart.tooltip.valuePrefix = ''
        @scope.chartOptions.options.yAxis.allowDecimals = false
      @scope.isEmptyChart = data.length == 0

      @scope.isLoading = false
    return

  CHART_TITLES:
    'views': 'Impressions'
    'clicks': 'Clicks'
    'budget_spent': 'Budget Spent'

angular
.module('stats.app')
.controller('StatsChartController', StatsChartController)
.requires.push 'highcharts-ng'
