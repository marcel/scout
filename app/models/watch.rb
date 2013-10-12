class Watch < ActiveRecord::Base
  belongs_to :player, inverse_of: :watches

  def voted_up?
    votes > 1
  end
end
