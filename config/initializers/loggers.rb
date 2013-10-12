ImportLog = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(Rails.root.join('log/import.log')))

module Scout
  module ImportLogging
    def import_log(message)
      ImportLog.tagged(name) do 
        ImportLog.info message
      end
    end
  end
end