class InboundMessageController < ApplicationController
  before_filter :authenticate_account!, except: [:sms, :email]
  
  #  MessageSid:
  #   A 34 character unique identifier for the message. May be used to later retrieve this message from the REST API.
  #  AccountSid:
  #   The 34 character id of the Account this message is associated with.
  #  From: 
  #   The phone number that sent this message.
  #  To: 
  #    The phone number of the recipient.
  #  Body:
  #   The text body of the message. Up to 1600 characters long.
  #
  # If available:
  # FromCity  The city of the sender
  # FromState The state or province of the sender.
  # FromZip The postal code of the called sender.
  # FromCountry The country of the called sender.
  # ToCity  The city of the recipient.
  # ToState The state or province of the recipient.
  # ToZip The postal code of the recipient.
  # ToCountry The country of the recipient.
  def sms
    account = Account.where(phone_number: params[:From].to_s[1..-1]).take
    respond_to do |format|
      format.xml do
        xml = Builder::XmlMarkup.new
        xml.Response do
          if account
            xml.Message("Roger that #{account.email}")
          end
        end
        
        render xml: xml.target!
      end
    end
  end
end
