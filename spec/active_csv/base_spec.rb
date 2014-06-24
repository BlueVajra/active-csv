require 'rspec'
require 'active_csv/base'
require 'csv'

describe ActiveCSV::Base do

  it "can be initialized with nothing" do
    active_csv = ActiveCSV::Base.new
    expect(active_csv).to be_kind_of(ActiveCSV::Base)
  end

  describe "attribute readers" do
    it "defines an attribute reader for every column in the csv" do
      row = CSV::Row.new(["name", "age"], ["joe", "24"])

      active_csv = ActiveCSV::Base.new(row)

      expect(active_csv.name).to eq("joe")
      expect(active_csv.age).to eq("24")
    end
  end

  describe ".file_path" do
    it "allows you to set the file path to the CSV" do
      klass = Class.new(ActiveCSV::Base) do
        self.file_path = "foo"
      end
      expect(klass.file_path).to eq("foo")
    end
  end

  it "returns error if the attributes don't exist" do
    row = CSV::Row.new(["name", "age"], ["joe", "24"])

    active_csv = ActiveCSV::Base.new(row)

    expect { active_csv.sex }.to raise_error(NoMethodError)
  end

  it "normalizes field headers" do
    row = CSV::Row.new(["FIrst   NAme  "], ["Joe"])
    active_csv = ActiveCSV::Base.new(row)
    expect(active_csv.first_name).to eq("Joe")
  end

  it "can remove prefixes to column names" do
    class MyClass < ActiveCSV::Base
      self.field_prefix = :usr_
    end

    instance = MyClass.new(CSV::Row.new(["usr_name", "usr_email"], ["jexample", "joe@example.com"]))
    actual = instance.name
    expected = "jexample"

    expect(actual).to eq expected
  end

  describe "class methods" do
    it ".all returns array of all csv rows" do
      class MyClass < ActiveCSV::Base
        self.file_path = File.absolute_path("spec/fixtures/sample.csv")
      end
      actual = MyClass.all
      expected = [
        CSV::Row.new(["id", "first_name"], ["4", "Joe"]),
        CSV::Row.new(["id", "first_name"], ["3", "Bob"]),
        CSV::Row.new(["id", "first_name"], ["5", "Bob"])
      ]

      expect(actual).to eq expected
    end

    it ".first returns object for first row" do
      class MyClass < ActiveCSV::Base
        self.file_path = File.absolute_path("spec/fixtures/sample.csv")
      end
      actual = MyClass.first
      expected = CSV::Row.new(["id", "first_name"], ["4", "Joe"])

      expect(actual).to eq expected
    end

    it ".last returns object for last row" do
      class MyClass < ActiveCSV::Base
        self.file_path = File.absolute_path("spec/fixtures/sample.csv")
      end
      actual = MyClass.last
      expected = CSV::Row.new(["id", "first_name"], ["5", "Bob"])

      expect(actual).to eq expected
    end

    it ".where returns filtered array of objects where proc is true" do
      class MyClass < ActiveCSV::Base
        self.file_path = File.absolute_path("spec/fixtures/sample.csv")
      end
      bob = Proc.new do |row|
        row.first_name=="Bob"
      end
      actual = MyClass.where(bob)
      expected = [
        CSV::Row.new(["id", "first_name"], ["3", "Bob"]),
        CSV::Row.new(["id", "first_name"], ["5", "Bob"])
      ]

      expect(actual).to eq expected
    end

    it ".order returns sorted array of objects where proc is order field" do
      class MyClass < ActiveCSV::Base
        self.file_path = File.absolute_path("spec/fixtures/sample.csv")
      end
      id = Proc.new do |x,y|
        x.id <=> y.id
      end
      actual = MyClass.order(id)
      expected = [
        CSV::Row.new(["id", "first_name"], ["3", "Bob"]),
        CSV::Row.new(["id", "first_name"], ["4", "Joe"]),
        CSV::Row.new(["id", "first_name"], ["5", "Bob"])
      ]

      expect(actual).to eq expected
    end
  end

end