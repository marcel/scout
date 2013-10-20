module Scout
  module SMS
    FROM = '+14154134445'
    
    class << self
      def send(account, message)
        Scout.sms.account.sms.messages.create(
          from: Scout::SMS::FROM,
          to: account.sms_phone_number,
          body: message
        )
      end
    end
  end
  
  class << self
    attr_reader :sms
  end

  @sms = Twilio::REST::Client.new(
    'ACad19952217effb6eaa14a11528236b37',
    '2b3054653c17b34896964b7bbc0834a7'
  )
end