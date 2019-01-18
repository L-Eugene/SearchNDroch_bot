# frozen_string_literal: true

require 'r18n-core'
require 'r18n-rails-api'

require 'r18n/snd_r18n_filters'

# SND module
module SND
  # I18n singleton
  class Localization
    include Singleton

    attr_reader :object

    def initialize
      @object = R18n.set('ru', "#{SND.libdir}/../i18n/")
    end
  end

  def self.t
    SND::Localization.instance.object.t
  end

  def self.l(*params)
    SND::Localization.instance.object.l(params)
  end
end
