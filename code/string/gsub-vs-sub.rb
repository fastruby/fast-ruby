require 'benchmark/ips'

URL = 'http://www.thelongestlistofthelongeststuffatthelongestdomainnameatlonglast.com/wearejustdoingthistobestupidnowsincethiscangoonforeverandeverandeverbutitstilllookskindaneatinthebrowsereventhoughitsabigwasteoftimeandenergyandhasnorealpointbutwehadtodoitanyways.html'

def fastest
  str = URL.dup
  str['http://'] = 'https://'
  str
end

def fast
  URL.sub('http://', 'https://')
end

def slow
  URL.gsub('http://', 'https://')
end

Benchmark.ips(quiet: true) do |x|
  x.report('String#dup["string"]=') { fastest }
  x.report('String#sub           ') { fast    }
  x.report('String#gsub          ') { slow    }
  x.compare!
end
