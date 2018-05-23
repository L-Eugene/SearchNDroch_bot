# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SND::Level do
  before(:each) do
    @level = FactoryGirl.create(:level)
  end

  it 'should provide needed attributes' do
    expect(@level).to respond_to(:id)
    expect(@level).to respond_to(:name)
    expect(@level).to respond_to(:task)
    expect(@level).to respond_to(:duration)
    expect(@level).to respond_to(:to_pass)
    expect(@level).to respond_to(:game)
  end
end
