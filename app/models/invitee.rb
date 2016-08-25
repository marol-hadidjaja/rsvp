class Invitee < ActiveRecord::Base
  belongs_to :event
  # belongs_to :user, dependent: :destroy
  validates_presence_of     :email, :name, :number, :relation
  # validates_presence_of     :name, :number, :relation
  validates_length_of       :email, :within => 3..100 # , allow_blank: true
  validates_uniqueness_of   :email, :case_sensitive => false # , allow_blank: true
  validates_format_of       :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i # , allow_blank: true
  validate :number_bigger_than_zero
  after_destroy :destroy_user

  def number_bigger_than_zero
    !self.number.nil? && self.number > 0
  end

  def self.to_csv
    attributes = %w{id email name number relation ceremonial_response reception_response number_of_response number_of_arrival}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |user|
        csv << attributes.map{ |attr| user.send(attr) }
      end
    end
  end

  def self.ceremonial_ok
    Invitee.where(ceremonial_response: true)
  end

  def self.reception_ok
    Invitee.where(reception_response: true)
  end

  def destroy_user
    User.where(email: email).destroy_all
  end
end
