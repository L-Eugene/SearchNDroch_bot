# frozen_string_literal: true

require 'db/snd_base'
require 'db/snd_code'

module SND
  # Level class
  class Level < SNDBase
    default_scope { order(id: :asc) }

    belongs_to :game
    has_many :codes, dependent: :destroy

    # @param [Hash] hash
    # @return [SND::Level]
    def self.create_level(hash)
      Level.create(hash.slice(:name, :task, :duration, :to_pass)).tap do |level|
        hash[:codes].each do |code|
          main = Code.create(value: code[:codes].shift, bonus: code[:bonus])
          level.codes << main
          code[:codes].each { |c| level.codes << Code.create(value: c, parent: main) }
        end
      end
    end

    # @param [String] code
    # @return [SND::Code]
    def check_code(code)
      codes.where(value: code)
    end

    def time_left_sec(chat_id = nil)
      lt = SND::LevelTime.find_by(chat_id: chat_id, level: self)

      duration.minutes - (Time.current.to_i - lt.start_time.to_i)
    end

    def time_left_min(chat_id = nil)
      lt = SND::LevelTime.find_by(chat_id: chat_id, level: self)

      (duration.minutes - (Time.current.to_i - lt.start_time.to_i)) / 60
    end

    def time_left(chat_id = nil)
      Time.at(time_left_sec(chat_id)).utc.strftime('%H:%M:%S')
    end

    def codes_left(chat)
      to_pass - codes.closed(chat.id).size
    end

    # @return [SND::Level] next level if current level is not the last one
    # @return [NilClass] nil if current level is the last one
    def next_level
      game.levels[game.levels.find_index { |level| level.id == id } + 1]
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
      codes.select { |code| code.id == code.parent.id }.each_with_index.map do |code, index|
        next if closed.include?(code.id) || code.parent.id != code.id

        index + 1
      end
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
