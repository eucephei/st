# == Schema Information
# Schema version: 20090701201617
#
# Table name: invoices
#
#  id                 :integer(4)      not null, primary key
#  donor_id           :integer(4)
#  type               :string(255)
#  notification_email :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#

class Pledge < Invoice
  belongs_to :donor 

  def add_donation(donation)
    unless donation == nil
      remove_donation_with_to_user_id(donation.to_user_id)
      donation.invoice = self
      donations << donation
    end
  end

  def remove_donation_with_to_user_id(to_user_id)
    donations.each do |d|
      if d.to_user_id == to_user_id.to_i
        donations.delete(d)
      end
    end
  end

  def find_donation_with_to_user_id (to_user_id)
    donations.each do |d|
      if d.to_user_id == to_user_id.to_i
        return d
      end
    end
    return
  end

  # Sort donations so that ST ask is alway at end of list
  def donations_sorted_for_display
    storg_id = Organization.find_savetogether_org.id
    donations.sort {|this, that|
      if this.to_user_id == storg_id
        1
      elsif that.to_user_id == storg_id
        -1
      elsif this.id && that.id
        this.id <=> that.id
      else
        0
      end
      }
  end
  
  # Filter out any $0 donations
  def billable_donations
    donations_sorted_for_display.reject{|d| d.amount.zero?}
  end

  def total_amount_for_donations
    total = Money.new(0)
    donations.each do |d|
      total = total + d.amount
    end
    return total
  end

  def set_donor_id(id)
    self.donor_id = id
    donations.each do |d|
      d.from_user_id = id
      d.save
    end
    save
  end

  def donation_attributes=(d_attributes)
    d_attributes.each do |index, attributes|
      amount = attributes[:amount]
      unless amount.blank? || amount == "0"
        donation = donations.build(attributes)
      end
    end
  end

  def process_paypal_notification(notify)
    # Verify Donation values against payment notification values
    # Then update status
    index = 1
    while item_number = notify.params["item_number#{index}"]
      saver = User.find(item_number)
      if saver.nil?
        raise ArgumentError, :argument_error_beneficiary_with_id_in_notification_not_found.l(:id => item_number)
      end

      amount = notify.params["mc_gross_#{index}"]
      line_item = self.donations.find(:first, :conditions => {:to_user_id => saver.id})
      if (line_item.nil?)
        raise "LineItem for user #{saver.id} not found"
      end

      line_item.status = notify.status
      line_item.save!
      index = index + 1
    end

    # Add reported Fee if it hasn't been reported already
    amount = notify.fee
    unless amount.nil?
      paypal = Organization.find_paypal_org
      fee = self.fees.find(:first, :conditions => {:to_user_id => paypal})
      if fee.nil?
        storg = Organization.find_savetogether_org
        self.fees << Fee.new(:from_user => storg, :to_user => paypal,
                :amount => amount, :status => notify.status)
      else
        fee.amount = amount
        fee.status = notify.status
        fee.save!
      end
    end

    if notify.status == LineItem::STATUS_COMPLETED
      UserNotifier.deliver_donation_thanks_notification(donor, self)      
    end
  end
end
