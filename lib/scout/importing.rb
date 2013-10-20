module Scout
  module Importing
    include Scout::ImportLogging
    
    def importing(week, &block)
      import_log "Started import at #{Time.zone.now}"
      yield
      import_log "Done at #{Time.zone.now}"
    rescue Exception => e
      summary = "[ALERT] Exception in #{name}.import: #{e.message}"
      details = "Exception! #{e.message}: #{e.backtrace.join("\n")}"
      if Rails.env.production?
        Scout::SMS.send_to_me(summary)
        Scout::Email.send_to_me(summary, details)
      end
      import_log details
    end
  end
end