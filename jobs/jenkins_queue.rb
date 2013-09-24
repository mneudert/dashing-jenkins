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

  api_url  = '%s/queue/api/json?tree=items[inQueueSince,task[color,name]]' \
             % [ settings.jenkins['url'].chomp('/') ]
  response = http.request(Net::HTTP::Get.new(api_url))
  items    = JSON.parse(response.body)['items']

  if items.empty?
    next
  end

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
