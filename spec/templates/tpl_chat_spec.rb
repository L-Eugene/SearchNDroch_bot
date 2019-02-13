# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SND::Tpl::Chat do
  it 'should generate pagination keyboard' do
    expect(SND::Tpl::Chat.keyboard_button('list', '/list 1')).to eq(text: 'list', callback_data: '/list 1')

    kbd = SND::Tpl::Chat.keyboard('list', 25, 1).inline_keyboard
    expect(kbd.size).to eq 1
    expect(kbd.first).to eq([text: '>', callback_data: '/list 2'])

    kbd = SND::Tpl::Chat.keyboard('list', 25, 2).inline_keyboard
    expect(kbd.first.size).to eq 2
    expect(kbd.first).to eq([{text: '<', callback_data: '/list 1'}, {text: '>', callback_data: '/list 3'}])

    kbd = SND::Tpl::Chat.keyboard('list', 25, 3).inline_keyboard
    expect(kbd.size).to eq 1
    expect(kbd.first).to eq([text: '<', callback_data: '/list 2'])
  end
end
