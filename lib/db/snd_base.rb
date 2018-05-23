# frozen_string_literal: true

require 'active_record'

# Search'N'Droch bot module
module SND
  # Basic class for AR
  class SNDBase < ActiveRecord::Base
    include R18n::Helpers
    self.abstract_class = true

    establish_connection(SND.cfg.options['database'])
    # @logger = SND.log
  end
end
