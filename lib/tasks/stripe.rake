namespace :stripe do
  unless ENV.has_key?('STRIPE_API_KEY')
    raise 'Failed to locate the Stripe API key. Please set STRIPE_API_KEY environment variable.'
  end

  namespace :plan do
    task sync: :environment do
      BUCKET_RANGES = [
        { bucket: 'AirborneBucket', range: 1..5 },
        { bucket: 'SoaringBucket', range: 6..15 },
        { bucket: 'CruisingBucket', range: 16..100 }
      ].freeze

      NAME_PREFIX = 'GliderPath TMS - '.freeze
      PLAN_PREFIX = 'tms.GliderPath'.freeze

      ActiveRecord::Base.transaction do
        puts "Fetching plans from Stripe\u2026\n"

        plan_options = Stripe::Plan.list
        plan_options = plan_options[:data].select { |plan| plan[:id].start_with?(PLAN_PREFIX) }

        puts "Stripe plans fetched successfully\u2026\n"
        puts "Inserting plans into the database\u2026\n"

        plan_options.each do |args|
          plan_name = args[:name].include?(NAME_PREFIX) ? args[:name].gsub(NAME_PREFIX, '') : args[:name]
          fetch_range = BUCKET_RANGES.detect { |plan| args[:id].match?(plan.fetch(:bucket)) }

          if Plan.where(stripe_plan_id: args[:id]).exists?
            puts "Plan \e[31m#{plan_name}\e[0m already exists!\n"
          else

            Plan.create!(
              billing_interval: args[:interval],
              name: plan_name,
              price: args[:amount] / 100,
              range: fetch_range[:range],
              stripe_plan_id: args[:id],
              trial_period_days: args[:trial_period_days]
            )

            print "\e[32m.\e[0m"
          end
        end

        print "\n"
        puts "\e[32mDone and dusted! ^_^\e[0m"
      end
    end
  end
end
