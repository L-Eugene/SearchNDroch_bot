# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SND::Monitoring do
  it 'should provide needed attributes' do
    monitoring = FactoryBot.create(:monitoring)
    expect(monitoring).to respond_to(:id, :value, :chat, :level, :code)
  end
end
