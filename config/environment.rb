# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Scout::Server::Application.initialize! unless Scout::Server::Application.initialized?