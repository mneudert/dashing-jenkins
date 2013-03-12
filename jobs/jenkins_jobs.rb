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
    jobs.map! do |job|
      { name: job['name'], state: job['color'] }
    end

    jobs.sort_by { |job| job['name'] }

    send_event('jenkins_jobs', { jobs: jobs })
  end
end