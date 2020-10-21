# frozen_string_literal: true

require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")

describe 'Game error classes' do
  before(:each) do
    @chat = FactoryBot.create(:user)
  end

  list = [
    { class: SND::InvalidGameNumberError, level: :warn },
    { class: SND::DefunctGameNumberError, level: :warn },
    { class: SND::GameOwnerError, level: :warn },
    { class: SND::TimeInPastError, level: :warn },
    { class: SND::InvalidTimeFormat, level: :warn },
    { class: SND::InvalidCodeFormat, level: :warn },
    { class: SND::InvalidFileExtension, level: :warn },
    { class: SND::AlreadyJoinedError, level: :warn },
    { class: SND::GameNotRunning, level: :warn },
    { class: SND::GameOver, level: :info },
    { class: SND::NoParametersGiven, level: :warn },
    { class: SND::FileParsingErrors, level: :warn },
    { class: SND::DeleteAfterStart, level: :warn }
  ]

  list.each do |node|
    it "should return valid log level for #{node[:class]}" do
      begin
        raise node[:class], data: [], chat: @chat
      rescue node[:class] => e
        expect(e.__send__(:log_level)).to be node[:level]
      end
    end
  end
end
