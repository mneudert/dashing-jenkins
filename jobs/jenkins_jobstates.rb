require 'net/http'
require 'json'

jenkins_host = '--- YOUR HOST HERE ---'
jenkins_view = '--- YOUR VIEW HERE ---'

SCHEDULER.every '2m', :first_in => 0 do
  http = Net::HTTP.new(jenkins_host)
  url  = '/view/%s/api/json' % jenkins_view

  response = http.request(Net::HTTP::Get.new(url))
  jobs     = JSON.parse(response.body)['jobs']

  if jobs
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
end