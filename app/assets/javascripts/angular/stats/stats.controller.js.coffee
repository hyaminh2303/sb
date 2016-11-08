class StatsController
  @$inject: ['$scope', '$http', '$rootScope']
  constructor: (@scope, @http, @rootScope) ->
    @dateFormat = 'dd MMM yy'
    @datepickers =
      startDate:
        opened: false
      endDate:
        opened: false

    @scope.campaignFilter =
      period: @FILTER_PERIODS[5]

    @rootScope.totalCampaigns = 0
    @rootScope.statsType = 'views'

    @scope.dateFilterOptions = @getDateFilterOptions(@FILTER_PERIODS[5].value)

    @scope.$on 'ClearStats', =>
      @setStats(null)

    @scope.$on 'SetStats', (e, stats)=>
      @setStats(stats)

    @setStats(null)
    return

  FILTER_PERIODS: [
    {text: 'Specific dates', value: ''}
    {text: 'Today', value: 'today'}
    {text: 'Yesterday', value: 'yesterday'}
    {text: 'This Week', value: 'this_week'}
    {text: 'Last Week', value: 'last_week'}
    {text: 'Last 7 Days', value: 'last_7_days'}
    {text: 'This Month', value: 'this_month'}
    {text: 'Last Month', value: 'last_month'}
  ]

  setStats: (stats)->
    @scope.views = stats && stats.views || 0
    @scope.clicks = stats && stats.clicks || 0
    @scope.budget = stats && stats.budget || '$0.00'

  filterByPeriodPreset: (item, model)->
    @scope.dateFilterOptions = @getDateFilterOptions(item.value)

  getDateFilterOptions: (period_preset) ->
    dateRange = null
    switch period_preset
      when 'today' then dateRange = [moment(), moment()]
      when 'yesterday' then dateRange = [moment().subtract(1, 'days'), moment().subtract(1, 'days')]
      when 'this_week' then dateRange = date_range = [moment().startOf('isoweek'), moment().endOf('isoweek')]
      when 'last_week' then dateRange = [moment().subtract(1, 'week').startOf('isoweek'), moment().subtract(1, 'week').endOf('isoweek')]
      when 'this_month' then dateRange = [moment().startOf('month'), moment().endOf('month')]
      when 'last_month' then dateRange = [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
      when 'last_7_days' then dateRange = [moment().subtract(7, 'days'), moment()]
      else dateRange = [moment().startOf('month'), moment().endOf('month')]

    {
    startDate: dateRange[0].format('DD MMM YY')
    endDate: dateRange[1].format('DD MMM YY')
    }

  openDatePopup: ($event, picker)->
    $event.preventDefault()
    $event.stopPropagation()
    @datepickers[picker].opened = true

  loadStatsChart: (statsType)=>
    @rootScope.statsType = statsType
    @rootScope.$broadcast('LoadStatsChart')

  setDateInYear: ()=>
    @scope.campaignFilter =
      period: @FILTER_PERIODS[0]
    @scope.dateFilterOptions =
      startDate: moment().subtract(1, 'year').startOf('year').format('DD MMM YY')
      endDate: moment().endOf('year').format('DD MMM YY')

angular
.module('stats.app')
.controller('StatsController', StatsController)

