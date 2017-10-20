require "benchmark/ips"

URL = "http://www.thelongestlistofthelongeststuffatthelongestdomainnameatlonglast.com/wearejustdoingthistobestupidnowsincethiscangoonforeverandeverandeverbutitstilllookskindaneatinthebrowsereventhoughitsabigwasteoftimeandenergyandhasnorealpointbutwehadtodoitanyways.html"

def fastest
  s = URL.dup
  s["http://"] = ""
end

def faster
  s = URL.dup
  s[%r{http://}] = ""
end

def fast
  s = URL.dup
  s.sub! "http://", ""
end

def slow
  s = URL.dup
  s.sub! %r{http://}, ""
end

def slower
  s = URL.dup
  s.gsub! "http://", ""
end

def slowest
  s = URL.dup
  s.gsub! %r{http://}, ""
end


Benchmark.ips(quiet: true) do |x|
  x.report("String#['string']=. ") { fastest }
  x.report("String#[/regexp/]=  ") { faster  }
  x.report("String#sub!'string' ") { fast    }
  x.report("String#sub!/regexp/ ") { slow    }
  x.report("String#gsub!'string'") { slower  }
  x.report("String#gsub!/regexp/") { slowest }
  x.compare!
end
