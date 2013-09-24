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

  api_url  = '%s/view/%s/api/json?tree=jobs[name,color]' \
             % [ settings.jenkins['url'].chomp('/'), settings.jenkins['view'] ]
  response = http.request(Net::HTTP::Get.new(api_url))
  jobs     = JSON.parse(response.body)['jobs']

  if jobs.empty?
    next
  end

  jobs.map! { |job|
    color = 'grey'

    case job['color']
    when 'blue', 'blue_anime'
      color = 'blue'
    when 'red', 'red_anime'
      color = 'red'
    end

    { name: job['name'], state: color }
  }

  jobs.sort_by { |job| job['name'] }

  send_event('jenkins_jobs', { jobs: jobs })
end
