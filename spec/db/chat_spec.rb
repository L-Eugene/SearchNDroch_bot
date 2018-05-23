# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'db/snd_chat'

describe SND::Chat do
  before(:each) do
    @chat = FactoryGirl.create(:user)
  end

  it 'should provide needed attributes' do
    expect(@chat).to respond_to(:id)
    expect(@chat).to respond_to(:chat_id)
    expect(@chat).to respond_to(:name)
  end
end
