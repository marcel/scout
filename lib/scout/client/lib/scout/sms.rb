module Scout
  module SMS
    FROM = '+14159801899'
    ME   = '+13122082298'
    class << self
      def send_to_account(account, message)
        send(account.sms_phone_number, message)
      end
      
      def send_to_me(message)
        send(ME, message)
      end
      
      def send(number, message)
        Scout.sms.account.messages.create(
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
    'ACdbe1a457d0534db7be1fe32dac0b0865',
    'bd0c446e37ec175564905f435ad9ff6b'
  )
end