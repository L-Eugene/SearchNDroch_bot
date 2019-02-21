# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'db/snd_code'

describe SND::Code do
  before(:each) do
    @code = FactoryBot.create(:code)
  end

  it 'should provide needed attributes' do
    expect(@code).to respond_to(:id)
    expect(@code).to respond_to(:value)
    expect(@code).to respond_to(:bonus)
    expect(@code).to respond_to(:level_id)
  end
end
