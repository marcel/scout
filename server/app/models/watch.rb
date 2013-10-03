class Watch < ActiveRecord::Base
  belongs_to :player

  def voted_up?
    votes > 1
  end
end
