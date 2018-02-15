# frozen_string_literal: true

PID_FILE = File.join(Rails.root, 'tmp', 'pids', 'sidekiq.pid')
LOG_FILE = File.join(Rails.root, 'tmp', 'sidekiq-log.log')

def read_pid
  return nil unless File.exists? PID_FILE
  pid = File.open(PID_FILE).read.strip
  pid.to_i unless pid.blank?
end

def write_pid(pid)
  unless File.directory?(File.dirname(PID_FILE))
    FileUtils.mkdir_p(File.dirname(PID_FILE))
  end
  File.open(PID_FILE, 'w') {|f| f.print pid }
end

def sidekiq_running?
  return false unless read_pid
  begin
    !!Process.getpgid(read_pid)
  rescue
    false
  end
end

def start_sidekiq
  unless sidekiq_running?
    write_pid(spawn("bundle exec sidekiq -L #{LOG_FILE}"))
  end
end

def stop_sidekiq
  Process.kill('HUP', read_pid) if sidekiq_running?
  File.open(PID_FILE, 'w') {}
  File.open(LOG_FILE, 'w') {}
end

def sidekiq_log
  File.read(LOG_FILE)
end

RSpec.configure do |config|
  config.before(:each) do |example|
    if example.metadata[:sidekiq]
      start_sidekiq
      Sidekiq::Testing.disable!
    end
  end

  config.after(:each) do |example|
    Sidekiq::Testing.fake! if example.metadata[:sidekiq]
  end

  config.after(:suite) do
    stop_sidekiq
  end
end