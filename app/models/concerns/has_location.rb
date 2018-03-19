module HasLocation
  extend ActiveSupport::Concern

  included do
    has_one :location, as: :addressable, dependent: :destroy

    accepts_nested_attributes_for :location,
                                  allow_destroy: true,
                                  reject_if: :all_blank

    def location_attributes=(attributes)
      super(attributes.merge(addressable: self))
    end
  end
end
