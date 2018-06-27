# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'db/snd_bonus'

describe SND::Bonus do
  before(:each) do
    @bonus = FactoryBot.create(:bonus)
  end

  it 'should provide needed attributes' do
    expect(@bonus).to respond_to(:id)
    expect(@bonus).to respond_to(:time)
    expect(@bonus).to respond_to(:code)
    expect(@bonus).to respond_to(:chat)
  end
end
