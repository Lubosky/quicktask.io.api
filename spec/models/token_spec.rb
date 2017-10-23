require 'rails_helper'

RSpec.describe Token, type: :model do
  it { should belong_to(:user).class_name('User').with_foreign_key(:subject_id) }
end
