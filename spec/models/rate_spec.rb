require 'rails_helper'

RSpec.describe Rate, type: :model do
  context 'validations' do
    it { should belong_to(:source_language).
      class_name('Language').
      with_foreign_key(:source_language_id).
      optional
    }
    it { should belong_to(:target_language).
      class_name('Language').
      with_foreign_key(:target_language_id).
      optional
    }
    it { is_expected.to belong_to(:task_type) }
    it { is_expected.to belong_to(:unit) }
    it { is_expected.to belong_to(:workspace) }
  end
end
