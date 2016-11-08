class MaintenanceController < ActionController::Base
  include ActionView::Helpers::DateHelper

  http_basic_authenticate_with :name => ENV['SIDEKIQ_USERNAME'], :password => ENV['SIDEKIQ_PASSWORD']

  layout 'maintenance'
  layout false, only: [:jobs]

  def index
    Setting.schedule_last_run = '' if Setting.schedule_last_run.nil?
  end

  def jobs

  end

  def get_schedule_frequency
    render json: {schedule_frequency: Setting.schedule_frequency}
  end

  def save_schedule_frequency
    frequency = params[:schedule_frequency].to_i
    Setting.schedule_frequency = frequency
    system "whenever --update-cron --set 'environment=#{Rails.env}&frequency=#{frequency * 60}'"
    render nothing: true, status: 200
  end

  def running_jobs
    workers = []
    Sidekiq::Workers.new.each do |process_id, thread_id, work|
      workers << {
          process_id: process_id,
          thread_id: thread_id,
          work: work,
          time_ago: "#{time_ago_in_words(Time.at(work['run_at']))} ago"
      }
    end

    render json: {
               workers: workers,
               last_run: if Setting.schedule_last_run == '' then 'never' else "#{time_ago_in_words(Setting.schedule_last_run)} ago" end
           }
  end

  def run_daily_tracking_worker
    DailyCampaignOptWorker.perform_async
    DailyCampaignWorker.perform_async
    render nothing: true, status: 200
  end
end
