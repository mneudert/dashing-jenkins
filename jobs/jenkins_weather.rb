require 'net/http'
require 'json'

jenkins_host = '--- YOUR HOST HERE ---'
jenkins_view = '--- YOUR VIEW HERE ---'

SCHEDULER.every '2m', :first_in => 0 do
  http = Net::HTTP.new(jenkins_host)
  url  = '/view/%s/api/json?tree=jobs[healthReport[iconUrl]]' % jenkins_view

  response = http.request(Net::HTTP::Get.new(url))
  jobs     = JSON.parse(response.body)['jobs']

  if jobs
    report = {
      '80plus' => 0,
      '60to79' => 0,
      '40to59' => 0,
      '20to39' => 0,
      '00to19' => 0
    }

    jobs.each { |job|
      next if not job['healthReport']
      next if not job['healthReport'][0]
      next if not job['healthReport'][0]['iconUrl']

      case job['healthReport'][0]['iconUrl']
      when 'health-80plus.png'
        report['80plus'] += 1
      when 'health-60to79.png'
        report['60to79'] += 1
      when 'health-40to59.png'
        report['40to59'] += 1
      when 'health-20to39.png'
        report['20to39'] += 1
      when 'health-00to19.png'
        report['00to19'] += 1
      end
    }

    send_event('jenkins_weather', { weather: report })
  end
end