class Estimator::Interpreting < Estimator::Base

  private

  def calculate_estimated_cost
    request.target_language_ids.sum do |target_language_id|
      service_tasks.sum do |service_task|
        params = rate_params(
          service_task: service_task,
          target_language_id: target_language_id
        )

        price = calculate_task_price(params)
        total_price(price)
      end
    end
  end

  def total_price(price)
    price * interpreter_count
  end

  def interpreter_count
    request.interpreter_count
  end
end
