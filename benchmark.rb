$LOAD_PATH.unshift  File.expand_path("./lib/", File.dirname(__FILE__))

require 'fingers'
require 'benchmark'

alphabet = 'asdfghjl'.split('')

Benchmark.bm do |x|
  x.report('huffman') { 1000.times { Huffman.new(alphabet: alphabet, n: 100).generate_hints(sort: false) } }
  x.report('huffman-sort') { 1000.times { Huffman.new(alphabet: alphabet, n: 100).generate_hints(sort: true) } }
end
