class Estimator::Other < Estimator::Base

  private

  def calculate_estimated_cost
    service_tasks.sum do |service_task|
      params = rate_params(
        service_task: service_task,
        target_language_id: nil
      )

      calculate_task_price(params)
    end
  end
end
