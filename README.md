goldfishdb
==========

Goldfish DB is a really simple database for in-memory Ruby objects. If you're
working with lots of ephemeral data that doesn't need to be persisted, but
that you need to be able to query in multiple ways, you might find it useful.

Goldfish provides a simple way of defining multiple indexes over a set of
data, taking care of the manual book-kepping that would otherwise be necessary
to maintain the indexes.

There are a few important reasons why this library might **not** be
appropriate for your use case:

  * No persistance - all data lives in memory and will disappear with your Ruby process.
  * Only supports querying for equality, i.e. range lookups aren't
  possible.
  * Currently **not** threadsafe.
  * There's no server component, so if multiple processes need to be
  able to access the data, it may not be appropriate.

Example
-------

```ruby
require "goldfish"

animals = Goldfish.table do |animal|
  # The block passed to the table method defines the primary key for
  # each object that will be added to the table.
  animal.id
end

animals.index(:name) { |animal| animal.name }

animals.index(:dangerous) do |animal|
  ["lion", "pirana", "tarantula"].includes? animal.type.downcase
end

# Queries return a DataSet object, which you can chain additional
# conditions on to:
dataset = animals.filter(dangerous: true)

dataset.map { |animal| animal.name } # => ["Lion", "Pirana"]

dataset.filter(name: "Lion").to_a # => ["Lion"]
```