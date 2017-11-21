class WorkspaceCurrency < ApplicationRecord
  self.table_name = :organization_currencies

  include EnsureUUID

  belongs_to :workspace, inverse_of: :supported_currencies

  before_validation { self.code.downcase! }

  validates :code, presence: true, uniqueness: { scope: :workspace_id }
  validates :exchange_rate, presence: true,
                            numericality: { greater_than: 0 }

  after_create :retrieve_exchange_rate

  def currency
    Money::Currency.new(code)
  end

  def self.build_for(workspace)
    workspace.supported_currencies.build(fixtures)
  end

  def self.create_for(workspace)
    workspace.supported_currencies.create(fixtures)
  end

  def self.fixtures
    YAML.load_file(Rails.root.join('config', 'fixtures', 'currencies.yml'))
  end

  private

  def retrieve_exchange_rate
    workspace.update_attribute(:currency, code) unless workspace.currency
    ExchangeRateUpdaterJob.perform_async(workspace_id, workspace.currency, code)
  end
end
