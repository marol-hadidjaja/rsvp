class Invitee < ActiveRecord::Base
  belongs_to :event
  belongs_to :user, dependent: :destroy
  validates_presence_of     :email, :name, :number, :relation
  validates_length_of       :email, :within => 3..100
  validates_uniqueness_of   :email, :case_sensitive => false
  validates_format_of       :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validates                 :email, :uniqueness => true, :presence => true
  validate :number_bigger_than_zero

  def number_bigger_than_zero
    !self.number.nil? && self.number > 0
  end

  def self.to_csv
    attributes = %w{id email name}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |user|
        csv << attributes.map{ |attr| user.send(attr) }
      end
    end
  end
end
