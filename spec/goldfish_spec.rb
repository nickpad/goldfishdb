require "goldfish"

describe Goldfish do
  describe ".table" do
    it "requires a block" do
      Proc.new { Goldfish.table }.must_raise ArgumentError
    end

    it "does not return nil" do
      Goldfish.table { |x| x.id }.wont_be_nil
    end
  end

  describe "#index" do
    let(:table) do
      Goldfish.table { |x| x.id }
    end

    it "returns the table" do
      table.index(:name) { |record| record.name }.must_equal table
    end
  end

  describe "Table instance" do
    let(:row) { Struct.new(:id) }

    let(:table) do
      Goldfish.table { |x| x.id }
    end

    describe "#insert" do
      it "adds the item to the table" do
        item = row.new(1)
        table.insert(row.new(1))
        table.fetch(1).must_equal item
      end
    end

    describe "#[]" do
      it "returns item with the given primary key" do
        item = row.new(1)
        table.insert(item)
        table[1].must_equal item
      end

      it "returns nil when key doesn't exist" do
        table["does-not-exist"].must_be_nil
      end
    end

    describe "#fetch" do
      it "returns item with the given primary key" do
        item = row.new(1)
        table.insert(item)
        table.fetch(1).must_equal item
      end

      it "raises when primary key doesn't exist" do
        Proc.new { table.fetch("does-not-exist") }.must_raise KeyError
      end

      it "allows caller to provide a default value" do
        table.fetch("does-not-exist", "default").must_equal "default"
      end
    end

    describe "#delete"  do
      it "removes item with given key from the table" do
        item = row.new(1)
        table.insert(item)
        table.delete(item.id)
        table[item.id].must_be_nil
      end

      it "returns the item deleted when key is present" do
        item = row.new(1)
        table.insert(item)
        table.delete(item.id).must_equal item
      end

      it "returns nil if not deleted" do
        table.delete("does-not-exist").must_be_nil
      end
    end

    describe "#delete_item" do
      it "removes an item from table" do
        item = row.new(1)
        table.insert(item)
        table.delete_item(item)
        table[1].must_be_nil
      end
    end

    describe "#filter" do
      it "returns a new dataset" do
        table.filter(id: 1).must_respond_to :filter
      end
    end
  end

  describe "DataSet instance" do
    describe "#delete_all" do
    end

    describe "#filter" do
    end
  end
end