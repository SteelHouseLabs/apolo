#!/usr/bin/env ruby
#
# Script Name:: db2_connection_qty.rb
# @author Efren Fuentes <efrenfuentes@gmail.com>
# @author Thomas Vincent <thomasvincent@steelhouselabs.com>
#
# Copyright 2014, Steel House Labs.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# This script checks the quantity of connections on the database. The quantity
# can be filtered by a given criterion, and inverted if wanted.

require 'apolo'
require 'optparse'


options = { critical: 101, warning: 101,
            instance: '/home/db2inst1', status: false, filter: nil, inverse: false }

begin
  OptionParser.new do |opts|
    opts.on('-c', '--critical MAX', 'Max connections for critical') { |v| options[:critical] = v }
    opts.on('-w', '--warning MAX', 'Max cpu usage percentage for warning') { |v| options[:warning] = v }
    opts.on('-i', '--instance DIRECTORY', 'Directory for DB2 instance') { |v| options[:instance] = v }
    opts.on('-d', '--database DATABASE', 'Database name') { |v| options[:database] = v }
    opts.on('-s', '--status', 'Show satus on message') { options[:status] = true }
    opts.on('-f', '--filter FILTER', 'Filter expression') { |v| options[:filtered] = v }
    opts.on('-n', '--inverse', 'Count connections not in filter') { options[:inverse] = true }
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

class CheckDB2ConnectionQty < Apolo::Metrics
  name 'DB2_Connection_Qty'

  # Nagios notifier
  notify Apolo::Notifiers::Nagios, file: 'nagios.cmd',\
                                   host: 'localhost',\
                                   service: 'DB2',\
                                   warning: @@options[:warning].to_i,\
                                   critical: @@options[:critical].to_i

  run do
    db2 = Apolo::Domains::DB2.new instance: @@options[:instance], database: @@options[:database]

    connections = db2.number_of_connections(@@options[filter], @@options[inverse])

    message = 'No connections found'
    value = 0

    unless connections.nil?
      message = "#{db2.database} Total of connections = #{connections[:total]}"
      value = connections[:total]

      if @@options[:status]
        message += " Connect Completed: #{connections[:connected]}"
        message += " UOW Executing: #{connections[:uow_executing]}"
        message += " UOW Waiting: #{connections[:uow_waiting]}"
        message += " Lock Wait: #{connections[:lock_wait]}"
        message += " Commit Active: #{connections[:commit]}"
        message += " Rollback: #{connections[:rollback]}"
        message += " Rollback to savepoint: #{connections[:rollback_to_savepoint]}"
        message += " Compiling: #{connections[:compiling]}"
        message += " Disconnecting: #{connections[:disconnecting]}"
        message += " Backup: #{connections[:backup]}"
        message += " Restore: #{connections[:restore]}"
        message += " Other: #{connections[:other]}"
      end
    end

    notify message: message, value: value

  end
end

puts @@options

# create monitor and run it
metrics = CheckDB2ConnectionQty.new
metrics.run