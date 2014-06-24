require 'csv'

module ActiveCSV
  class Base
    @@file_path
    def initialize(csv="")
      if csv != ""
        edited_csv = normalizeHeaders(csv)
        @csv = CSV::Row.new(edited_csv[0], edited_csv[1])
      else
        @csv = csv
      end
    end

    def self.file_path
      @@file_path
    end

    def self.file_path=(path)
      @@file_path = path
    end

    def self.all
      array_of_rows = []
      csv = CSV.read(self.file_path, headers: true)
      csv.each do |row|
        array_of_rows << row
      end
      array_of_rows
    end

    def self.first
      csv = CSV.read(self.file_path, headers: true)
      csv.first
    end

    def self.last
      csv = CSV.read(self.file_path, headers: true)
      csv[csv.length-1]
    end

    def method_missing(method_name)
      @csv[method_name.to_s] || super
    end

    def respond_to_missing?(method_name)
      !@csv[method_name.to_s].nil? || super
    end

    private

    def normalizeHeaders(csv)
      transposed_csv = csv.to_a.transpose
      transposed_csv[0].map! do |header|
        header.downcase.strip.gsub(/\s+/, "_")
      end
      transposed_csv
    end
  end
end