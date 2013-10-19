# This file is used by Rack-based servers to start the application.

# Unicorn self-process killer
require 'unicorn/worker_killer'

# Max memory size (RSS) per worker. Restart a unicorn if it exceeds 512MB RSS, check every 25 requests.
use Unicorn::WorkerKiller::Oom, (192*(1024**2)), (512*(1024**2)), 25

require ::File.expand_path('../config/environment',  __FILE__)
run Rails.application
