#!/usr/bin/env ruby
# This script checks for database size, can use percentage if wanted.
require 'apolo'
require 'optparse'

# @author Efren Fuentes <efrenfuentes@gmail.com>
# @author Thomas Vincent <thomasvincent@steelhouselabs.com>

options = { warning: 101, critical: 101, instance: '/home/db2inst1', refresh: -1, percentage: false }

begin
  OptionParser.new do |opts|
    opts.on('-c', '--critical MAX', 'Max connections for critical') { |v| options[:critical] = v }
    opts.on('-w', '--warning MAX', 'Max cpu usage percentage for warning') { |v| options[:warning] = v }
    opts.on('-i', '--instance DIRECTORY', 'Directory for DB2 instance') { |v| options[:instance] = v }
    opts.on('-d', '--database DATABASE', 'Database name') { |v| options[:database] = v }
    opts.on('-r', '--refresh REFRESH', 'Quantity of minutes before refresh cache in the database. Used to call GET_DBSIZE_INFO.') { |v| optiond[:refresh] = v }
    opts.on('-p' '--percentage', 'Check for percentage of use') { options[:percentage] = true}
  end.parse!
rescue Exception => msg
  puts msg
  exit
end

# Supress warning messages.
original_verbose, $VERBOSE = $VERBOSE, nil
@@options = options
# Activate warning messages again.
$VERBOSE = original_verbose

class CheckDB2DatabaseSize < Apolo::Metrics
  name 'DB2_Database_Size'

  # Nagios notifier
  notify Apolo::Notifiers::Nagios, file: 'nagios.cmd',\
                                   host: 'localhost',\
                                   service: 'DB2',\
                                   warning: @@options[:warning].to_i,\
                                   critical: @@options[:critical].to_i

  run do
    db2 = Apolo::Domains::DB2.new instance: @@options[:instance], database: @@options[:database]

    if @@options[:percentage]
      value = db2.database_size_percentage(@@options[:refresh])
      message = "#{db2.database} percentage of size"
    else
      value = db2.database_size(@@options[:refresh])
      message = "#{db2.database} size"
    end

    notify message: message, value: value

  end
end

puts @@options

# create monitor and run it
metrics = CheckDB2DatabaseSize.new
metrics.run