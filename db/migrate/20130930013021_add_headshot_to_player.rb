class AddHeadshotToPlayer < ActiveRecord::Migration
  def change
    change_table :players do |t|
      t.string :headshot
    end
  end
end
