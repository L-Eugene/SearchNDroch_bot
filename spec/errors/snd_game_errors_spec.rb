# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe 'Game error classes' do
  it 'should return valid log levels' do
    list = [
      { class: SND::InvalidGameNumberError, level: :warn },
      { class: SND::DefunctGameNumberError, level: :warn },
      { class: SND::GameOwnerError, level: :warn },
      { class: SND::TimeInPastError, level: :warn },
      { class: SND::InvalidTimeFormat, level: :warn },
      { class: SND::AlreadyJoinedError, level: :warn },
      { class: SND::GameNotRunning, level: :warn },
      { class: SND::DeleteAfterStart, level: :warn }
    ]

    list.each do |node|
      begin
        raise node[:class]
      rescue node[:class]
        expect($ERROR_INFO.__send__(:log_level)).to be node[:level]
      end
    end
  end
end
