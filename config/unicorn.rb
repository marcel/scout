root = "/home/scout/production/current"
working_directory root
listen 8080
worker_processes 4
preload_app true
timeout 30
pid "#{root}/tmp/pids/unicorn.pid"
user "scout", "scout"
stderr_path "#{root}/log/unicorn.log"
stdout_path "#{root}/log/unicorn.log"

before_exec do |_|
  ENV["BUNDLE_GEMFILE"] = File.join(root, 'Gemfile')
end

before_fork do |server, worker|

  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|

  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to sent QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end