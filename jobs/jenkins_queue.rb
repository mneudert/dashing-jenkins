require 'net/http'
require 'json'

jenkins_host = '--- YOUR HOST HERE ---'

SCHEDULER.every '2m', :first_in => 0 do
  http = Net::HTTP.new(jenkins_host)
  url  = '/queue/api/json'

  response = http.request(Net::HTTP::Get.new(url))
  items    = JSON.parse(response.body)['items']

  if items
    items.sort_by { |item| item['inQueueSince'] }
    items.reverse!

    items = items[0..7]

    items.map! { |item|
      color = 'grey'

      case item['task']['color']
      when 'blue', 'blue_anime'
        color = 'blue'
      when 'red', 'red_anime'
        color = 'red'
      end

      { name:  item['task']['name'], state: color }
    }

    send_event('jenkins_queue', { items: items })
  end
end