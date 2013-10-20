module Scout
  module Email
    FROM = 'Scout Rank <alert@scoutrank.co>'
    ME   = 'scoutrank@marcelmolina.com'
    
    class << self
      def send_to_account(account, subject, message)
        send(account.email, subject, message)
      end
      
      def send_to_me(message)
        send(ME, message)
      end
      
      def send(email, subject, message)
        Scout.mailer.messages.send_email(
          from: Scout::Email::FROM,
          to: email,
          subject: subject,
          text: message
        )
      end
    end
  end
  
  class << self
    attr_reader :mailer
  end
  
  Mailgun.configure do |config|
    config.api_key = 'key-3w76vsdzohvhsx94vee3xlzwj68mjfj5'
    config.domain  = 'scoutrank.co'
  end

  @mailer = Mailgun(api_key: Mailgun.api_key, domain: Mailgun.domain)
end
