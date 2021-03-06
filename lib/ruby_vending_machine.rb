# frozen_string_literal: true

require 'json'
require 'tty-prompt'
require 'colorize'
require_relative 'app/version'
require_relative 'app/application'

module RubyVendingMachine
  # class to describe Vending Machine terminal ruby application runner
  class ApplicationRunner
    attr_reader :products_json, :coins_json

    def initialize(coins_file_path:, products_file_path:)
      products_file = File.open(products_file_path)
      coins_file = File.open(coins_file_path)
      @products_json = ::JSON.parse(products_file.read, symbolize_names: true)
      @coins_json = ::JSON.parse(coins_file.read, symbolize_names: true)
    end

    def self.call(options)
      new(options).call
    end

    def call
      application = RubyVendingMachine::Application.new(
        products: products_json,
        coins: coins_json
      )
      RubyVendingMachine::ApplicationWindow.run(application)
    end
  end
end
