# frozen_string_literal: true

module SND
  # Chat /name command processor
  module ChatCommand
    def cmd_name(args)
      raise SND::NoParametersGiven if args.empty?

      chat.update!(name: args.join(' '))
    end
  end
end
