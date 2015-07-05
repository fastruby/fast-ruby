require "benchmark/ips"

URL = "http://www.thelongestlistofthelongeststuffatthelongestdomainnameatlonglast.com/wearejustdoingthistobestupidnowsincethiscangoonforeverandeverandeverbutitstilllookskindaneatinthebrowsereventhoughitsabigwasteoftimeandenergyandhasnorealpointbutwehadtodoitanyways.html"

def fast
  s = URL.dup
  s["http://"] = ""
end

def slow_1
  s = URL.dup
  s.sub! "http://", ""
end

def slow_2
  s = URL.dup
  s.gsub! "http://", ""
end

def slow_3
  s = URL.dup
  s[%r{http://}] = ""
end

def slow_4
  s = URL.dup
  s.sub! %r{http://}, ""
end

def slow_5
  s = URL.dup
  s.gsub! %r{http://}, ""
end


Benchmark.ips do |x|
  x.report("String#['string']=")   { fast   }
  x.report("String#sub!'string'")  { slow_1 }
  x.report("String#gsub!'string'") { slow_2 }
  x.report("String#[/regexp/]=")   { slow_3 }
  x.report("String#sub!/regexp/")  { slow_4 }
  x.report("String#gsub!/regexp/") { slow_5 }
  x.compare!
end
