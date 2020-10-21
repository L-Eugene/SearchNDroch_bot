# frozen_string_literal: true

require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")
require 'db/snd_code'

describe SND::Code do
  before(:each) do
    @code = FactoryBot.create(:code)
  end

  it 'should provide needed attributes' do
    expect(@code).to respond_to(:id, :value, :bonus, :level_id, :parent)
  end

  it 'should save secondary codes' do
    code2 = SND::Code.create(value: 'code2', parent: @code)

    expect(code2.parent.id).to eq @code.id
  end
end
