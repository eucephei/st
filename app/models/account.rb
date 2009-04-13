# == Schema Information
# Schema version: 20090408231608
#
# Table name: accounts
#
#  id         :integer(4)      not null, primary key
#  owner_id   :integer(4)
#  owner_type :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Account < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true
  has_many :donation_line_items  
end
