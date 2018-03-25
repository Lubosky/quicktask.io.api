class Estimator::Localization < Estimator::Base

  private

  def calculate_estimated_cost
    request.target_language_ids.sum do |target_language_id|
      service_tasks.sum do |service_task|
        params = rate_params(
          service_task: service_task,
          target_language_id: target_language_id
        )

        calculate_task_price(params)
      end
    end
  end
end
