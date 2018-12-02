# frozen_string_literal: true

module FasterCacheKeys
  def cache_key
    "#{self.class.table_name}/#{id}-#{read_attribute_before_type_cast(:updated_at)}"
  end
end
