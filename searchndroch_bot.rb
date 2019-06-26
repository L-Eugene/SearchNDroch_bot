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

Dir.glob(
  %w[r18n errors commands templates log db telegram parser].map { |s| "#{SND.libdir}/#{s}/snd_*.rb" }
).each { |f| require f }

# Set timezone
Time.zone = SND.cfg.options['timezone']

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

    process_message(update.message) unless update.message.nil?
    process_callback(update.callback_query) unless update.callback_query.nil?
  rescue SND::ErrorBase
    $ERROR_INFO.process
  rescue StandardError
    SND.log.error "#{$ERROR_INFO.message}\n#{$ERROR_INFO.backtrace.join("\n")}"
  end

  def process_message(message)
    @chat = SND::Chat.identify(message)
    @time = Time.at(message.date)

    if message.text
      meth = method_from_message(message.text.gsub(%r{@[a-zA-Z0-9]}, ''))
      args = args_from_message(%r{^\/\w+\s?}, message.text.gsub(%r{@[a-zA-Z0-9]}, ''))
      process_command(meth, args) if respond_to?(meth.to_sym, true)
      cmd_code(message.text)
    elsif message.document
      process_file(message.document)
    end
  end

  def process_callback(callback)
    @chat = SND::Chat.identify(callback.message)
    @time = Time.current

    SND.tlg.api.answer_callback_query(callback_query_id: callback.id)
    return unless callback.data

    meth = method_from_message(callback.data)
    args = args_from_message(%r{^\/\w+\s?}, callback.data) + [callback.message.message_id]
    process_command(meth, args) if respond_to?(meth.to_sym, true)
  end

  # Start/stop games by cron, check level autocomplete
  def periodic
    SND.log.debug 'Periodic actions start'
    SND::Game.game_operations
    SND::Game.start_games
    SND.log.debug 'Periodic actions end'
  end

  private

  def method_from_message(text)
    meth = (text || '').downcase
    log = meth[0] == '/'

    [%r{\@.*$}, %r{\s.*$}, %r{^/}].each { |x| meth.gsub!(x, '') }

    if log
      SND.log.info "#{meth} command from #{chat.chat_id}"
      SND.log.debug "Full command is #{text}"
    end

    "cmd_#{meth}"
  end

  def args_from_message(preg, msg)
    msg.gsub(preg, '').gsub(%r{\s+}m, ' ').strip.split(' ')
  end

  def process_command(meth, args)
    result = nil
    # rubocop:disable Style/FormatStringToken
    SND.log.debug Benchmark.measure(meth) { result = __send__(meth, args) }
                           .format('%n: user:%u CPU:%y total:%t %r')
    # rubocop:enable Style/FormatStringToken
    result
  end

  def process_file(document)
    file = SND::Tlg.instance.download_file(document)
    ext = File.extname(file.path).delete('.')

    game_hash = SND::Parser.parse(file, ext, @chat)
    file.unlink

    chat.own_games << SND::Game.create_game(game_hash)
  end
end
