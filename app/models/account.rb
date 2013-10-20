class Account < ActiveRecord::Base
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :watches, inverse_of: :account

  def watch_for(player)
    Scout.cache.fetch(['watch', player, cache_key]) {
      watches.where(player_id: player.id).take
    }
  end
end