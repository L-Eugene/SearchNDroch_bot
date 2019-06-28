# frozen_string_literal: true

require 'singleton'

# Vk module
module SND
  # Telegram connection singleton
  class Tlg
    include Singleton

    attr_reader :client

    def initialize
      @token = SND.cfg.options['tg_token']
      @client = Telegram::Bot::Client.new(@token)
    end

    def self.escape(text)
      text.gsub(%r{([\*_])}) { |x| "\\#{x}" }
    end

    def download_file(document)
      Tempfile.open(['snd_game', File.extname(document.file_name)]).tap do |f|
        f.write Net::HTTP.get(get_file_uris(document))
        f.close
      end
    end

    def get_file_uri(document)
      file_path = client.api.get_file(file_id: document.file_id)
      file_path = file_path['result']['file_path'] if file_path['ok']

      URI.parse "https://api.telegram.org/file/bot#{@token}/#{file_path}"
    end
  end

  def self.tlg
    SND::Tlg.instance.client
  end
end
