#!/usr/bin/env ruby

require_relative './input_socket'

InputSocket.new.send(ARGV[0])
