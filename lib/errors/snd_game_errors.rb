# frozen_string_literal: true

require 'errors/snd_error_base'

module SND
  # Game number given is not a positive number
  class InvalidGameNumberError < ErrorBase
    private

    def default_message
      SND.t.error.invalid_game_number.log
    end

    def default_cmessage
      SND.t.error.invalid_game_number.msg
    end

    def log_level
      :warn
    end
  end

  # Game with such number does not exists
  class DefunctGameNumberError < ErrorBase
    private

    def default_message
      SND.t.error.defunct_game_number.log
    end

    def default_cmessage
      SND.t.error.defunct_game_number.msg
    end

    def log_level
      :warn
    end
  end

  # Operation need owner privilegies
  class GameOwnerError < ErrorBase
    private

    def default_message
      SND.t.error.game_owner.log
    end

    def default_cmessage
      SND.t.error.game_owner.msg
    end

    def log_level
      :warn
    end
  end

  # Game start time in past
  class TimeInPastError < ErrorBase
    private

    def default_message
      SND.t.error.time_in_past.log
    end

    def default_cmessage
      SND.t.error.time_in_past.msg
    end

    def log_level
      :warn
    end
  end

  # Time format is invalid
  class InvalidTimeFormat < ErrorBase
    private

    def default_message
      SND.t.error.invalid_time_format.log
    end

    def default_cmessage
      SND.t.error.invalid_time_format.msg
    end

    def log_level
      :warn
    end
  end

  # Already registered to game
  class AlreadyJoinedError < ErrorBase
    private

    def default_message
      SND.t.error.already_joined.log
    end

    def default_cmessage
      SND.t.error.already_joined.msg
    end

    def log_level
      :warn
    end
  end

  # Game is not running yet
  class GameNotRunning < ErrorBase
    private

    def default_message
      SND.t.error.game_not_running.log
    end

    def default_cmessage
      SND.t.error.game_not_running.msg
    end

    def log_level
      :warn
    end
  end

  # Trying to delete game after it started
  class DeleteAfterStart < ErrorBase
    private

    def default_message
      SND.t.error.delete_after_start.log
    end

    def default_cmessage
      SND.t.error.delete_after_start.msg
    end

    def log_level
      :warn
    end
  end
end
