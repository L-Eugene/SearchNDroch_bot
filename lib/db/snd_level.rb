# frozen_string_literal: true

require 'db/snd_base'
require 'db/snd_code'

module SND
  # Level class
  class Level < SNDBase
    belongs_to :game
    has_many :codes, dependent: :destroy

    # @param [Hash] hash
    # @return [SND::Level]
    def self.create_level(hash)
      Level.create(hash.slice(:name, :task, :duration, :to_pass)).tap do |level|
        hash[:codes].each { |c| level.codes << Code.create(value_hash: c[:code], bonus: c[:bonus]) }
      end
    end

    # @param [String] code
    # @return [SND::Code]
    def check_code(code)
      codes.where(value_hash: Digest::MD5.hexdigest(code)).first
    end

    def time_left_sec(_chat_id = nil)
      # length of all previous levels in minutes
      prev = game.time_to_level(self).minutes

      duration.minutes - (Time.now.to_i - game.start.to_i - prev)
    end

    def time_left(chat_id = nil)
      Time.at(time_left_sec(chat_id)).utc.strftime('%H:%M:%S')
    end

    # If array contains less than 3 elements, all of them are listed
    # only first and last elements are displayed other way
    # @param [Array<Integer>] list
    # @return [String]
    def compact_list(list)
      list.size < 3 ? list.join(',') : "#{list.min}-#{list.max}"
    end

    # Return list of unclosed codes ID for given chat
    # @param [Integer] chat_id
    # @return [Array<Integer>]
    def chat_unclosed_indexes(chat_id)
      closed = codes.closed(chat_id).order(:id).ids
      codes.each_with_index.map { |code, index| index + 1 unless closed.include?(code.id) }
    end

    # @param [SND::Chat] chat_id
    # @return [Hash]
    def chat_stat(chat_id)
      closed = codes.closed(chat_id)
      {
        left: group_indexes(chat_unclosed_indexes(chat_id)).join(','),
        left_count: to_pass - closed.size,
        codes: closed.size,
        points: closed.map(&:bonus).inject(0, &:+),
        time: time_left(chat_id)
      }
    end

    # Remove empty subarrays and compact lists
    # @param [Array<Integer>] data
    # @return [Array<String>]
    def group_indexes(data)
      [[]].tap { |result| data.each { |ind| ind.nil? ? (result << []) : (result.last << ind) } }
          .reject(&:empty?).map { |x| compact_list(x) }
    end

    private :compact_list, :group_indexes, :chat_unclosed_indexes
  end
end
