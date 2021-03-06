require "set"

class Goldfish
  def self.table(&block)
    fail ArgumentError, "block required" unless block_given?
    Table.new(&block)
  end

  class SecondaryIndex
    def initialize(&block)
      @keys = {}
      @ids = {}
      @block = block
    end

    def get(id)
      @keys[id] || Set.new
    end

    def add(item, pk)
      id = @block.call(item)
      @keys[id] = get(id).add(pk)
      @ids[pk] = get(id)
    end

    def remove(pk)
      set = @ids[pk]
      set.delete(pk) if set
    end
  end

  class DataSet
    include Enumerable

    class Filter
      def initialize(table, options)
        @table = table
        @options = options
      end

      def apply(keys)
        @options.each do |index_name, id|
          index = @table.indexes[index_name]

          if index
            if keys
              keys = keys & index.get(id)
            else
              keys = index.get(id)
            end
          else
            fail ArgumentError, "Invalid index: #{index_name}"
          end
        end

        keys
      end
    end

    def initialize(table, query = [])
      @table = table
      @query = query
    end

    def filter(options)
      updated_query = @query + [Filter.new(@table, options)]
      DataSet.new(@table, updated_query)
    end

    def size
      self.to_a.size
    end

    def each(&block)
      matching_keys = @query.inject(nil) do |keys, clause|
        clause.apply(keys)
      end

      matching_keys.to_a.each { |key| yield @table.data[key] }
    end
  end

  class Table
    include Enumerable

    attr_reader :data, :indexes

    def initialize(&block)
      @data = {}
      @indexes = {}
      @block = block
    end

    def index(name, &block)
      self.tap do
        @indexes[name] = block
      end
    end

    def fetch(*args)
      @data.fetch(*args)
    end

    def [](key)
      @data[key]
    end

    def insert(item)
      pk = @block.call(item)
      @data[pk] = item
      @indexes.each { |_, idx| idx.add(item, pk) }
    end

    def delete(key)
      @data.delete(key).tap do
        @indexes.each { |_, idx| idx.remove(key) }
      end
    end

    def delete_item(item)
      key = @block.call(item)
      delete(key)
    end

    def filter(options)
      DataSet.new(self).filter(options)
    end

    def each
      @data.values.each { |item| yield item }
    end

    def size
      @data.size
    end
  end
end