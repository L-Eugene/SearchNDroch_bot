# frozen_string_literal: true

module SND
  # Chat /name command processor
  module ChatCommand
    def cmd_name(args)
      raise SND::NoParametersGiven if args.empty?

      chat.update!(name: args.join(' '))
      chat.send_message(text: SND.t.name.success(name: chat.name))
    end
  end
end
