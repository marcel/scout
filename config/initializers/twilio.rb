module Scout
  module SMS
    FROM = '+14154134445'
    ME   = '+13122082298'
    class << self
      def send_to_account(account, message)
        send(account.sms_phone_number, message)
      end
      
      def send_to_me(message)
        send(ME, message)
      end
      
      def send(number, message)
        Scout.sms.account.sms.messages.create(
          from: Scout::SMS::FROM,
          to: number,
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