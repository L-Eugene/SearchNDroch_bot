# frozen_string_literal: true

require 'English'
require 'benchmark'
require 'active_support/all'
require 'telegram/bot'
require 'active_record'
require 'net/http'
require 'yaml'
require 'uri'
require 'unicode'

# SearchNDroch Bot namespace
module SND
  # Configuration class
  class Config
    include Singleton

    attr_reader :options

    CONFIG_PATH = "#{__FILE__}.yml"

    def initialize
      @options = YAML.load_file CONFIG_PATH
    end
  end

  def self.cfg
    SND::Config.instance
  end

  def self.libdir
    "#{File.dirname(__FILE__)}/#{SND.cfg.options['libdir']}"
  end
end

$LOAD_PATH.unshift(SND.libdir)

Dir["#{SND.libdir}/r18n/snd_*.rb"].each { |f| require f }

require 'log/snd_logger'
Dir["#{SND.libdir}/errors/snd_*.rb"].each { |f| require f }
Dir["#{SND.libdir}/commands/snd_*.rb"].each { |f| require f }
Dir["#{SND.libdir}/templates/snd_*.rb"].each { |f| require f }
require 'parser/snd_spreadsheet_parser'
require 'telegram/snd_telegram'
require 'db/snd_game'
require 'db/snd_chat'

# Main class for Search'N'Droch bot
class SearchndrochBot
  include SND::ChatCommand

  attr_reader :token, :client, :chat

  def initialize
    @token = SND.cfg.options['tg_token']
    @client = Telegram::Bot::Client.new(@token)
  end

  def update(data)
    update = Telegram::Bot::Types::Update.new(data)
    message = update.message
    @time = Time.at(message.date)

    process_message(message) unless message.nil?
  rescue SND::ErrorBase
    $ERROR_INFO.process
  rescue StandardError
    SND.log.error "#{$ERROR_INFO.message}\n#{$ERROR_INFO.backtrace.join("\n")}"
  end

  def process_message(message)
    @chat = SND::Chat.identify(message)

    if message.text
      meth = method_from_message(message.text)
      args = args_from_message(%r{^\/\w+\s?}, message.text)
      process_command(meth, args) if respond_to?(meth.to_sym, true)
      cmd_code(message.text)
    elsif message.document
      process_file(message.document)
    end
  end

  # Start/stop games by cron
  def periodic
    SND::Game.game_operations
    SND::Game.start_games
  end

  private

  def method_from_message(text)
    meth = (text || '').downcase
    [%r{\@.*$}, %r{\s.*$}, %r{^/}].each { |x| meth.gsub!(x, '') }

    SND.log.info "#{meth} command from #{chat.chat_id}"
    SND.log.debug "Full command is #{text}"

    "cmd_#{meth}"
  end

  def args_from_message(preg, msg)
    msg.gsub(preg, '').gsub(%r{\s+}m, ' ').strip.split(' ')
  end

  def process_command(meth, args)
    result = nil
    SND.log.debug Benchmark.measure(meth) { result = __send__(meth, args) }
                           .format('%n: user:%u CPU:%y total:%t %r') # rubocop:disable Style/FormatStringToken
    result
  end

  def process_file(document)
    file = SND::Tlg.instance.download_file(document)
    ext = File.extname(file.path).delete('.')
    raise SND::InvalidFileExtension unless %w[ods xls xlsx].include? ext

    game = parse_spreadsheet(file, ext.to_sym)
    file.unlink

    chat.own_games << SND::Game.create_game(game)
  end

  def parse_spreadsheet(file, ext)
    sp = SND::SpreadsheetParser.new(file, extension: ext)
    raise SND::FileParsingErrors, data: sp.errors, chat: @chat unless sp.valid?

    sp.to_hash
  end
end
