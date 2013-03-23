require 'net/http'
require 'json'

jenkins_host = '--- YOUR HOST HERE ---'
jenkins_view = '--- YOUR VIEW HERE ---'

SCHEDULER.every '2m', :first_in => 0 do
  http = Net::HTTP.new(jenkins_host)
  url  = '/view/%s/api/json?tree=jobs[name,color]' % jenkins_view

  response = http.request(Net::HTTP::Get.new(url))
  jobs     = JSON.parse(response.body)['jobs']

  if jobs
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
end