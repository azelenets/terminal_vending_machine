# frozen_string_literal: true

require 'json'
require 'tty-prompt'
require 'colorize'
require 'figlet'
require 'lolcat'
require_relative 'ruby_vending_machine/version'
require_relative 'ruby_vending_machine/application'

module RubyVendingMachine
  class Error < StandardError; end

  class ApplicationRunner
    attr_reader :products_json

    def initialize(products_file_path:)
      products_file = File.open(products_file_path)
      @products_json = ::JSON.parse(products_file.read, symbolize_names: true)
    end

    def self.call(options)
      new(options).call
    end

    def call
      application = RubyVendingMachine::Application.new(
        products: products_json
      )
      application.run
    end
  end
end
