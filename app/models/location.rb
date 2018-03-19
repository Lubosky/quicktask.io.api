class Location < ApplicationRecord
  include EnsureUUID

  belongs_to :addressable, polymorphic: true
  belongs_to :workspace

  validates :address, :workspace, presence: true
  validates_associated :addressable

  geocoded_by :address do |object, location|
    object.geocode_address(location)
  end

  before_validation { self.workspace ||= addressable&.workspace }
  before_validation :normalize_address
  after_validation :geocode, if: :address_changed?

  def self.normalize_address(address)
    return address.blank? ? nil : address.strip
  end

  def geocode_address(address)
    if geocoded = address.first
      self.street_name = geocoded&.route
      self.street_number = geocoded&.street_number
      self.city = geocoded&.city
      self.state = geocoded&.state
      self.postal_code = geocoded&.postal_code
      self.country = geocoded&.country
      self.formatted_address = geocoded&.formatted_address
      self.latitude = geocoded&.latitude
      self.longitude = geocoded&.longitude
      self.coordinates = geocoded&.coordinates
    end
  end

  private

  def normalize_address
    self.address = self.class.normalize_address(address)
  end
end
