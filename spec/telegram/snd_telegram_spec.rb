# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SND::Tlg do
  before(:all) do
    @file_path = "#{File.dirname(__FILE__)}/../fixtures/telegram"
  end

  it 'should escape messages' do
    expect(SND::Tlg.escape('*text* _text_')).to eq '\*text\* \_text\_'
  end

  it 'should calculate file download URL' do
    doc = double('Document', file_id: 'file_id_stub')
    allow(SND::Tlg.instance.client.api).to receive(:get_file).with(file_id: 'file_id_stub') do
      YAML.load_file("#{@file_path}/file_document.yml")
    end

    expect(SND::Tlg.instance.get_file_uri(doc)).to eq(URI.parse('https://api.telegram.org/file/botsometoken/test_file_path'))
  end
end
