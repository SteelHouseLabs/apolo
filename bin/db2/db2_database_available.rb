#!/usr/bin/env ruby
# This script checks if database is available for connect.
require 'apolo'
require 'optparse'

# @author Efren Fuentes <efrenfuentes@gmail.com>
# @author Thomas Vincent <thomasvincent@steelhouselabs.com>

options = { warning: 1, critical: 2, instance: '/home/db2inst1' }

begin
  OptionParser.new do |opts|
    opts.on('-i', '--instance DIRECTORY', 'Directory for DB2 instance') { |v| options[:instance] = v }
    opts.on('-d', '--database DATABASE', 'Database name') { |v| options[:database] = v }
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

class CheckDB2DatabaseAvailable < Apolo::Metrics
  name 'DB2_Database_Available'

  # Nagios notifier
  notify Apolo::Notifiers::Nagios, file: 'nagios.cmd',\
                                   host: 'localhost',\
                                   service: 'DB2',\
                                   warning: @@options[:warning].to_i,\
                                   critical: @@options[:critical].to_i

  run do
    db2 = Apolo::Domains::DB2.new instance: @@options[:instance], database: @@options[:database]

    value = 3 # error
    message = "#{db2.database} is not available for connect"

    if db2.connectable?
      value = 0 # ok
      message = "#{db2.database} is available for connect"
    elsif db2.quiesce_mode?
      value = 1 # warning
      message = "#{db2.database} is on quiesce mode"
    end

    notify message: message, value: value

  end
end

puts @@options

# create monitor and run it
metrics = CheckDB2DatabaseAvailable.new
metrics.run