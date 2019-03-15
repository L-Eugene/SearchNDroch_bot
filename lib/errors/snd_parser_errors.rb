# frozen_string_literal: true

require 'errors/snd_error_base'

module SND
  # Invalid file extension
  class InvalidFileExtension < ErrorBase
    private

    def default_message
      SND.t.error.invalid_file_extension.log
    end

    def default_cmessage
      SND.t.error.invalid_file_extension.msg
    end

    def log_level
      :warn
    end
  end

  # File parsing errors exception
  class FileParsingErrors < ErrorBase
    private

    def default_message
      SND.t.error.game_parsing_errors.log
    end

    def default_cmessage
      SND.t.error.game_parsing_errors.msg errors: @data.map { |err| "- #{err}" }.join("\n")
    end

    def log_level
      :warn
    end
  end
end
