require 'net/http'
require 'json'

http = nil

SCHEDULER.every '2m', :first_in => 0 do
  if not defined? settings.jenkins?
    next
  end

  if nil == http
    url  = URI.parse(settings.jenkins['url'])
    http = Net::HTTP.new(url.host, url.port)

    if ('https' == url.scheme)
      http.use_ssl     = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
  end

  api_url  = '%s/view/%s/api/json?tree=jobs[color]' \
             % [ settings.jenkins['url'].chomp('/'), settings.jenkins['view'] ]
  response = http.request(Net::HTTP::Get.new(api_url))
  jobs     = JSON.parse(response.body)['jobs']

  if jobs.empty?
    next
  end

  blue = 0
  red = 0
  grey = 0

  jobs.each { |job|
    case job['color']
    when 'blue', 'blue_anime'
      blue += 1
    when 'red', 'red_anime'
      red += 1
    else
      grey += 1
    end
  }

  send_event('jenkins_jobstates', { blue: blue, red: red, grey: grey })
end
