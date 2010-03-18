class AddColumnToSaver < ActiveRecord::Migration
  def self.up
  	add_column  :users, :special_msg, :string	#!! saver writes special_msg 
  end

  def self.down
    remove_column  :users, :special_msg			#!! saver writes special_msg 	
  end
end
