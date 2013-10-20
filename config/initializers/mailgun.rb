module Scout
  class << self
    attr_reader :mailer
  end
  
  Mailgun.configure do |config|
    config.api_key = 'key-3w76vsdzohvhsx94vee3xlzwj68mjfj5'
    config.domain  = 'scoutrank.co'
  end
  
  @mailer = Mailgun(api_key: Mailgun.api_key, domain: Mailgun.domain)
end
