class Team::Rate::Create < ApplicationInteractor
  integer :owner_id
  integer :source_language_id, default: nil
  integer :target_language_id, default: nil
  integer :task_type_id, default: nil
  integer :unit_id, default: nil

  decimal :price, default: nil

  string :rate_type

  def execute
    transaction do
      unless rate.save
        errors.merge!(rate.errors)
        rollback
      end
    end
    rate
  end

  private

  def rate
    @rate ||= build_rate
  end

  def build_rate
    case rate_type.to_sym
    when :client_default
      parent.default_client_rates.build(rate_attributes)
    when :contractor_default
      parent.default_contractor_rates.build(rate_attributes)
    when :contractor
      parent.contractor_rates.build(rate_attributes)
    when :client
      parent.client_rates.build(rate_attributes)
    else
      nil
    end
  end

  def rate_attributes
    attributes.slice(
      :source_language_id,
      :target_language_id,
      :task_type_id,
      :unit_id,
      :price
    )
  end

  def parent
    @_parent ||=
      case rate_type.to_sym
      when :client_default then current_workspace
      when :contractor_default then current_workspace
      when :contractor then ::Contractor.find(attributes[:owner_id])
      when :client then ::Client.find(attributes[:owner_id])
      else
        nil
      end
  end
end
