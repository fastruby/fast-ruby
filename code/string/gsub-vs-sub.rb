require 'benchmark/ips'

URL = 'http://www.thelongestlistofthelongeststuffatthelongestdomainnameatlonglast.com/wearejustdoingthistobestupidnowsincethiscangoonforeverandeverandeverbutitstilllookskindaneatinthebrowsereventhoughitsabigwasteoftimeandenergyandhasnorealpointbutwehadtodoitanyways.html'

def slow
  URL.gsub('http://', 'https://')
end

def fast
  URL.sub('http://', 'https://')
end

Benchmark.ips do |x|
  x.report('String#gsub') { slow }
  x.report('String#sub')  { fast }
  x.compare!
end
