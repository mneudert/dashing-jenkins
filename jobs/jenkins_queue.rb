require 'net/http'
require 'json'

jenkins_host = '--- YOUR HOST HERE ---'

SCHEDULER.every '2m', :first_in => 0 do
  http = Net::HTTP.new(jenkins_host)
  url  = '/queue/api/json' % jenkins_view

  response = http.request(Net::HTTP::Get.new(url))
  items    = JSON.parse(response.body)['items']

  if items
    items.sort_by { |item| item['inQueueSince'] }
    items.reverse!

    items = items[0..7]

    items.map! do |item|
      { name:  item['task']['name'], state: item['task']['color'] }
    end

    send_event('jenkins_queue', { items: items })
  end
end