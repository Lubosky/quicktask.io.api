class Workspace < ApplicationRecord
  self.table_name = :organizations

  include EnsureUUID

  belongs_to :owner, inverse_of: :workspaces, class_name: 'User', foreign_key: :owner_id

  has_one :membership, inverse_of: :workspace, dependent: :destroy

  before_validation :generate_unique_slug, on: :create

  validates :slug, :name, :owner_id, presence: true
  validates :slug, length: { minimum: 2, maximum: 18 },
                   uniqueness: { conditions: -> { where(deleted_at: nil) } }

  enum status: { pending: 0, active: 1, deactivated: 2 } do
    event :activate do
      transition all - [:active] => :active
    end

    event :deactivate do
      transition all - [:deactivated] => :deactivated
    end
  end

  def generate_unique_slug
    self.slug ||= slugify
  end

  private

  def slugify
    SlugGenerator.slugify(self.name)
  end
end
