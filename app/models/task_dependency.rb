class TaskDependency < ApplicationRecord
  with_options class_name: 'Task' do
    belongs_to :dependent_task, foreign_key: :task_id, inverse_of: :dependent_task_relations
    belongs_to :precedent_task, foreign_key: :dependent_on_task_id, inverse_of: :precedent_task_relations
  end

  scope :for_task, ->(task) {
    where(task: task).or(where(dependent_on_task: task))
  }

  scope :inverted, ->(dependency) {
    table = TaskDependency.arel_table
    condition = table[:task_id].eq(dependency.dependent_on_task_id)
    inverted_condition = table[:dependent_on_task_id].eq(dependency.task_id)

    where(condition.and(inverted_condition))
  }

  validates :dependent_task, :precedent_task, presence: true
  validates :dependent_task, exclusion: { in: ->(record) { [record.precedent_task] } }
  validate :validate_circular_dependency

  def validate_circular_dependency
    if TaskDependency.inverted(self).exists?
      errors.add(:base, :taken)
      throw(:abort)
    end
  end
end
