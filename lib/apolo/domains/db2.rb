module Apolo
  module Domains
    # Get data from DB2 instance
    #
    # @author Efren Fuentes <efrenfuentes@gmail.com>
    class DB2
      attr_reader :database

      def initialize(options = {})
        @instance = options[:instance]
        @database = options[:database].upcase

        unless @instance && @database
          raise ArgumentError, 'You need to set :instance and :database to use DB2.'
        end

        unless exist?
          raise ArgumentError, "Database #{@database} don't exist"
        end
      end

      # Get list of databases on DB2 directory
      def databases
        `db2 list db directory | awk '/Database alias/ {print $4}'`.split
      end

      # Database exist?
      def exist?
        databases.include?(@database)
      end

      # Get list of active databases
      def active_databases
        `db2 list active databases  | awk '/Database name/ {print $4}'`.split
      end

      # Is database active?
      def active?
        active_databases.include?(@database)
      end

      # Is database connectable?
      def connectable?
        sql_code_for_connect == 0
      end

      # Is quiesce mode
      def quiesce_mode?
        sql_code_for_connect == -20157
      end

      # Get sql code for connect to database
      def sql_code_for_connect
        result = `db2 -a connect to #{@database} | awk '/sqlcode/ {print $7}'`
        result.to_i
      end

      # Get database size
      def database_size(refresh=-1)
        result = `db2 connect to #{database} > /dev/null ; db2 "CALL GET_DBSIZE_INFO(?, ?, ?, #{refresh})" ; db2 connect reset > /dev/null`

        lines = result.split("\n")

        (lines.count == 13) ? lines[7].split[3].to_i : -1
      end

      # Get database capacity
      def database_capacity(refresh=-1)
        result = `db2 connect to #{database} > /dev/null ; db2 "CALL GET_DBSIZE_INFO(?, ?, ?, #{refresh})" ; db2 connect reset > /dev/null`

        lines = result.split("\n")

        (lines.count == 13) ? lines[10].split[3].to_i : -1
      end

      # Get database size percentage
      def database_size_percentage(refresh=-1)
        result = `db2 connect to #{database} > /dev/null ; db2 "CALL GET_DBSIZE_INFO(?, ?, ?, #{refresh})" ; db2 connect reset > /dev/null`

        lines = result.split("\n")

        percentage = -1
        if lines.count == 13
          size = lines[7].split[3].to_i
          allocated = lines[10].split[3].to_i
          percentage = size * 100 / allocated
        end

        percentage
      end

      # Get number of connections
      def number_of_connections(filter=nil, inverse=false)
        applications = `db2 list applications for database #{@database}`.split("\n")

        if applications[0] =~ /\ASQL30082N/
          # security problem with user and/or password
          raise StandardError, applications[0]
        end

        if applications[0] =~ /\ASQL1611W/
          # No data return (no connections)
          return nil
        end

        connections = applications[4..applications.count - 2]

        # Apply filter
        unless filter.nil?
          filtered = connections.grep(/#{filter}/i)
          filtered = connections - filtered if inverse
          connections = filtered
        end

        total = connections.count
        backup=0
        commit=0
        compiling=0
        connected=0
        disconnecting=0
        lock_wait=0
        restore=0
        rollback=0
        rollback_to_savepoint=0
        uow_executing=0
        uow_waiting=0
        other=0

        connections.each do |connection|
          backup                += 1 if connection =~ /Performing a Backup/
          commit                += 1 if connection =~ /Commit Active/
          compiling             += 1 if connection =~ /Compiling/
          connected             += 1 if connection =~ /Connect Completed/
          disconnecting         += 1 if connection =~ /Disconnect Pending/
          lock_wait             += 1 if connection =~ /Lock-wait/
          restore               += 1 if connection =~ /Restoring Database/
          rollback              += 1 if connection =~ /Rollback Active/
          rollback_to_savepoint += 1 if connection =~ /Rollback to Savepoint/
          ouw_executing         += 1 if connection =~ /UOW Executing/
          ouw_waiting           += 1 if connection =~ /UOW Waiting/
        end

        other = total - (backup + commit + compiling + connected + disconnecting +
                         lock_wait + restore + rollback + rollback_to_savepoint +
                         uow_executing + uow_waiting)

        result = {total:                 total,
                  backup:                backup,
                  commit:                commit,
                  compiling:             compiling,
                  connected:             connected,
                  disconnecting:         disconnecting,
                  lock_wait:             lock_wait,
                  restore:               restore,
                  rollback:              rollback,
                  rollback_to_savepoint: rollback_to_savepoint,
                  uow_executing:         uow_executing,
                  uow_waiting:           uow_waiting,
                  other:                 other}

        return result
      end
    end
  end
end
