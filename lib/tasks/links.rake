namespace :links do
  require 'net/http'

  desc 'Check if the links are reachable. The current status has an influence of 1%. Run this Task as a cron every x minutes.'
  task :check_links => :environment do
    Link.all.each do |link|
      success = false
      begin
        uri = URI(link.uri)
        res = Net::HTTP.get_response(uri)
        if res.is_a? Net::HTTPSuccess or res.is_a? Net::HTTPRedirection
          success = true
        end
      rescue
        success = false
      end
      link.last_check = success
      if success && link.uptime == 0.0
        link.uptime = 100.0
      elsif success
        link.uptime = link.uptime * 0.99 + 1
      else
        link.uptime = link.uptime * 0.99
      end
      link.touch
      link.save
    end
  end
end
