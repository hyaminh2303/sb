# Root crumb
crumb :root do
  link 'Home', root_path
end

# thhoang FIXME change link later on
crumb :campaigns_detail do
  link 'Campaign Detail', root_path
end
# Advertiser list
# crumb :advertisers do
#   link t('views.breadcrumbs.advertisers.index'), advertisers_path
# end
#
# # Advertiser
# crumb :advertiser do |model|
#   link model.name, model
#   parent :advertisers
# end
#
# # Publisher list
# crumb :publishers do
#   link t('views.breadcrumbs.publishers.index'), publishers_path
# end
#
# # Publisher
# crumb :publisher do |publisher|
#   link publisher.new_record? ? t('views.breadcrumbs.publishers.new') : publisher.name, publisher
#   parent :publishers
# end
#
# # Campaign list
# crumb :campaigns do
#   link t('views.breadcrumbs.campaigns.index'), campaigns_path
# end
#
# # Campaign
# crumb :campaign do |model|
#   link model.new_record? ? t('views.breadcrumbs.campaigns.new') : model.name, model
#   parent :campaigns
# end
#
# # Campaign Ads Group list
# crumb :campaign_ads_groups do
#   link t('views.breadcrumbs.campaign_ads_groups.index'), campaign_ads_group_index_path
#   parent :campaigns
# end
#
# # Campaign Ads Group
# crumb :campaign_ads_group do |model|
#   link model.new_record? ? t('views.breadcrumbs.campaign_ads_groups.new') : t('views.breadcrumbs.campaign_ads_groups.edit')
#   parent :campaign_ads_groups
# end
#
# # Daily tracking
# crumb :daily_tracking do
#   link t('views.breadcrumbs.daily_trackings.daily_update'), new_campaign_daily_tracking_path
#   parent :root
# end
#
# # Import Daily tracking
# crumb :daily_trackings_import do
#   link t('views.breadcrumbs.daily_trackings.import')
#   parent :daily_tracking
# end
#
# # Location tracking lists
# crumb :location_trackings do
#   link t('views.breadcrumbs.location_trackings.location_update'), campaign_location_trackings_path
#   parent :root
# end
#
# # Campaign group stats
# crumb :campaign_group_stats do |campaign|
#   link t('views.breadcrumbs.campaign_stats.group'), index_campaign_group_stats_path(campaign.id)
#   parent :root
# end
#
# crumb :campaign_group_details do |campaign|
#   if campaign.has_ads_group?
#     link t('views.breadcrumbs.campaign_stats.detail')
#     parent :campaign_group_stats, campaign
#   else
#     link t('views.breadcrumbs.campaign_stats.campaign_detail')
#     parent :root
#   end
# end
#
# #Location
# crumb :location_tracking do |model|
#   link model.new_record? ? t('views.breadcrumbs.location_trackings.new') : t('views.breadcrumbs.location_trackings.edit')
#   parent :location_trackings
# end
#
# # Import Location tracking
# crumb :location_trackings_import do
#   link t('views.breadcrumbs.location_trackings.import')
#   parent :location_trackings
# end
#
# # Order list
# crumb :orders do
#   link t('views.breadcrumbs.orders.index'), orders_path
# end
#
# # Order
# crumb :order do |model|
#   link model.new_record? ? t('views.breadcrumbs.orders.new') : model.name, model
#   parent :orders
# end
#
# # Location list
# crumb :locations do
#   link t('views.breadcrumbs.locations.index'), locations_path
# end
#
# # Location
# crumb :location do |model|
#   link model.new_record? ? t('views.breadcrumbs.locations.new') : model.name, model
#   parent :locations
# end
#
# # Import Location
# crumb :location_import do
#   link t('views.breadcrumbs.locations.import')
#   parent :locations
# end
#
# # Location Lists list
# crumb :location_lists do
#   link t('views.breadcrumbs.location_lists.index'), location_lists_path
# end
#
# # Location List
# crumb :location_list do |model|
#   link model.new_record? ? t('views.breadcrumbs.location_lists.new') : model.name, model
#   parent :location_lists
# end
#
# # Platforms list
# crumb :platforms do
#   link t('views.breadcrumbs.platforms.index'), platforms_path
# end
#
# # Platform
# crumb :platform do |model|
#   link model.new_record? ? t('views.breadcrumbs.platforms.new') : model.name, model
#   parent :platforms
# end
#
# # Agencies List
# crumb :agencies do
#   link t('views.breadcrumbs.agencies.index'), agencies_path
# end
#
# # Agency Lists
# crumb :agency do |model|
#   link model.new_record? ? t('views.breadcrumbs.agencies.new') : model.name, model
#   parent :agencies
# end
#
# # Currencies List
# crumb :currencies do
#   link t('views.breadcrumbs.currencies.index'), currencies_path
# end
#
# # Currency
# crumb :currency do |model|
#   link model.new_record? ? t('views.breadcrumbs.currencies.new') : model.name, model
#   parent :currencies
# end
#
# # Roles List
# crumb :roles do
#   link t('views.breadcrumbs.roles.index'), roles_path
# end
#
# # Role
# crumb :role do |model|
#   link model.new_record? ? t('views.breadcrumbs.roles.new') : model.name, model
#   parent :roles
# end
#
# # Users List
# crumb :users do
#   link t('views.breadcrumbs.users.index'), users_path
# end
#
# # User
# crumb :user do |model|
#   link model.new_record? ? t('views.breadcrumbs.users.new') : model.name, model
#   parent :users
# end

# crumb :projects do
#   link "Projects", projects_path
# end

# crumb :project do |project|
#   link project.name, project_path(project)
#   parent :projects
# end

# crumb :project_issues do |project|
#   link "Issues", project_issues_path(project)
#   parent :project, project
# end

# crumb :issue do |issue|
#   link issue.title, issue_path(issue)
#   parent :project_issues, issue.project
# end

# If you want to split your breadcrumbs configuration over multiple files, you
# can create a folder named `config/breadcrumbs` and put your configuration
# files there. All *.rb files (e.g. `frontend.rb` or `products.rb`) in that
# folder are loaded and reloaded automatically when you change them, just like
# this file (`config/breadcrumbs.rb`).