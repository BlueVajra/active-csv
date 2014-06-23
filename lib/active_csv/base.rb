require 'csv'

module ActiveCSV
  class Base
    def initialize(csv="")
      @csv = csv
      @file_path
    end

    def self.file_path
      @file_path
    end

    def self.file_path=(path)
      @file_path = path
    end

    def method_missing(method_name)
      @csv[method_name.to_s] || nil
    end

    def respond_to_missing?(method_name)
      !@csv[method_name].nil? || super
    end
  end
end