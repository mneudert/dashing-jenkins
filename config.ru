require 'dashing'

configure do
  set :jenkins, {
    'url'  => 'https://jenkins.domain:8081/path/to/index',
    'view' => 'All'
  }
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application
