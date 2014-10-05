require 'sequel'
require 'sqlite3'
require 'date'

module Apolo
  module Notifiers
    class Sqlite
    def initialize(options = {})
      @db_name = options[:db_name]
      @db_table = options[:db_table]

      unless @db_name && @db_table
        raise ArgumentError, 'You need to set :db_name and :db_table to use sqlite notify.'
      end

      @db = Sequel.sqlite database: @db_name

      @db.create_table?(@db_table.to_sym) do
        primary_key :id
        DateTime :created_at
        String :monitor
        String :message
        Float :value
      end
    end

    def notify(monitor, message, value)
      @db[@db_table.to_sym].insert(created_at: DateTime.now, monitor: monitor,\
                            message: message, value: value)
    end
    end
  end
end
