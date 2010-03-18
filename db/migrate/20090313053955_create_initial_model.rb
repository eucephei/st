class CreateInitialModel < ActiveRecord::Migration
  def self.up
    create_table :invoices, :options => "auto_increment = #{Time.now.to_i}" do |t|
      t.integer :donor_id
      t.string :type
      t.string :notification_email
      t.timestamps
    end

    create_table :line_items do |t|
      t.integer :cents
      t.integer :invoice_id
      t.integer :from_user_id
      t.integer :to_user_id
      t.string :status, :default => LineItem::STATUS_PENDING
      t.string :type
      t.timestamps
    end

    create_table :asset_types do |t|
      t.string :asset_name
      t.timestamps
    end

    add_column(:users, :type, :string)
    add_column(:users, :requested_match_cents, :integer)
    add_column(:users, :asset_type_id, :integer)
    add_column(:users, :organization_id, :integer)
    add_column(:users, :first_name, :string)
    add_column(:users, :last_name, :string)
    add_column(:users, :web_site_url, :string)
    add_column(:users, :phone_number, :string)
    add_column(:users, :notify_advocacy, :boolean)

    create_table :payment_notifications do |t|
      t.text :raw_data
      t.timestamps
    end

    create_table :organization_surveys do |t|
      t.integer :organization_id
      t.string :contact_email
      t.string :year_founded
      t.string :annual_operating_expenses
      t.integer :total_matched_accounts
      t.string :year_first_accounts_opened
      t.integer :number_of_active_accounts
      t.timestamps
    end

    create_table :donor_surveys do |t|
      t.integer :donor_id
      t.boolean :add_me_to_cfed_petition, :default => false
    end
  end

  def self.down
    drop_table :donor_surveys
    drop_table :organization_surveys
    drop_table :payment_notifications
    remove_column(:users, :notify_advocacy)
    remove_column(:users, :phone_number)
    remove_column(:users, :web_site_url)
    remove_column(:users, :last_name)
    remove_column(:users, :first_name)
    remove_column(:users, :organization_id)
    remove_column(:users, :asset_type_id)
    remove_column(:users, :requested_match_cents)
    remove_column(:users, :type)	
    drop_table :asset_types
    drop_table :line_items
    drop_table :invoices
   end
end
