require 'rails_helper'

class DummyClass
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  attr_accessor :record_id
  attr_accessor :other_record_id

  def record
    OpenStruct.new id: 12388, workspace_id: 34522
  end

  def other_record
    OpenStruct.new id: 16215, workspace_id: 31565
  end

  include BelongsDirectly
  belongs_directly_to :record
  belongs_directly_to :other_record
end

class OtherDummyClass
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  attr_accessor :other_id

  def parent
    OpenStruct.new id: 12388, record_id: 34522
  end

  include BelongsDirectly
  belongs_directly_to :parent, foreign_key: :other_id, primary_key: :record_id
end

class AnotherDummyClass
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  attr_accessor :record_id

  def record
    nil
  end

  include BelongsDirectly
  belongs_directly_to :record
end

RSpec.describe BelongsDirectly do
  context 'default behaviour' do
    subject { DummyClass.new }
    before(:each) do
      subject.valid?
    end

    it 'should set correct record_id' do
      expect(subject.record_id).to eq(12388)
    end

    it 'should set correct other_record_id' do
      expect(subject.other_record_id).to eq(16215)
    end
  end

  context ':foreign_key and :primary_key' do
    subject { OtherDummyClass.new }
    before(:each) do
      subject.valid?
    end

    it 'should set correct record_id' do
      expect(subject.other_id).to eq(34522)
    end
  end

  context 'with empty parent' do
    subject { AnotherDummyClass.new }
    before(:each) do
      subject.valid?
    end

    it 'should set correct record_id' do
      expect(subject.record_id).to be(nil)
    end
  end
end
