# frozen_string_literal: true

require 'errors/snd_error_base'

module SND
  # Raised if no parameter given for command
  class NoParametersGiven < ErrorBase
    private

    def default_message
      SND.t.error.no_parameters_given.log
    end

    def default_cmessage
      SND.t.error.no_parameters_given.msg
    end

    def log_level
      :warn
    end
  end
end
