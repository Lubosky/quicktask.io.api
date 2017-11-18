class Guest
  include NullUser

  attr_accessor :email

  def initialize(email: nil)
    @email = email
  end

  NIL_METHODS = [:id, :created_at, :presence, :persisted?]
  FALSE_METHODS = [:save, :persisted?]

  NIL_METHODS.each   { |method| define_method(method, -> { nil }) }
  FALSE_METHODS.each { |method| define_method(method, -> { false }) }

  def errors
    ActiveModel::Errors.new self
  end

  def status
    :untapped
  end
end
