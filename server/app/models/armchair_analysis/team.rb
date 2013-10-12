class ArmchairAnalysis::Team < ActiveRecord::Base
  belongs_to :game, {
    primary_key: :gid,
    foreign_key: :gid,
    class_name: "ArmchairAnalysis::Game"
  }
  
  # acts_as_cabalist({
  #   features: [:pts, :sk, :int, :fum, :pu, :pen, :rza, :bry, :bpy, :mpc, :lpc, :l3c, :l3a, :s3a, :s3c, :dum],
  #   class_variable: :dp,
  #   collection: :all
  # })
end