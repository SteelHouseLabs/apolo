#
# Script Name:: cpu_sockets.rb
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


# Get information about percentage of usage for each cpu on all sockets

module Apolo
  module Domains
    class CpuSocket
      def initialize
        @init_stats = statistics_of_process
        sleep 1
        @end_stats = statistics_of_process
      end

      # Get number of cpus for each socket
      #
      # @return [Integer] the number of cpus for sockets
      def cpu_socket
        cpus / (sockets + 1)
      end

      # Get usage for cpus
      #
      # @return [Integer] the usage for cpus
      def usage_sum(cores, stats)
        usage_sum = 0

        cores.each do |core|
          line = stats[core + 1].split(' ')
          usage_sum = line[1].to_i + line[2].to_i + line[3].to_i
        end

        usage_sum
      end

      # Get total of process
      #
      # @return [Integer] the total of process
      def proc_total(cores, stats)
        proc_total = 0
        (1..4).each do |i|
          cores.each do |core|
            line = stats[core + 1].split(' ')
            proc_total += line[i].to_i
          end
        end
        proc_total
      end

      # Get usage for each cpu
      #
      # @return [Array] the percentage of usage for each cpu
      def cpu_usage
        cpu_usage = []
        (0..sockets).each do |socket|
          cores = (socket * cpu_socket..socket * cpu_socket + (cpu_socket - 1))

          init_usage = usage_sum(cores, @init_stats)
          end_usage = usage_sum(cores, @end_stats)

          proc_usage = end_usage - init_usage

          init_total = proc_total(cores, @init_stats)
          end_total = proc_total(cores, @end_stats)

          proctotal = (end_total - init_total)

          usage = (proc_usage.to_f / proctotal.to_f)

          cpu_usage[socket] = (100 * usage).to_f
        end
        cpu_usage
      end

      # Get number of sockets
      #
      # @return [Integer] the number of sockets on system
      def sockets
        File.readlines('/proc/cpuinfo').grep(/^physical id/).last.split(' ')[3].to_i
      end

      # Get number of cpus
      #
      # @return [Integer] the number of cpus on system
      def cpus
        File.readlines('/proc/cpuinfo').grep(/^processor/).count
      end

      private

      # Get statistics of process
      #
      # @return [Array] the statistics of process
      def statistics_of_process
          File.readlines('/proc/stat')
      end
    end
  end
end