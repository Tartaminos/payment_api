require 'sidekiq'
require 'sidekiq-scheduler'

Sidekiq::Scheduler.reload_schedule!