require 'benchmark/ips'

HASH = {
  'provider' => 'facebook',
  'uid' => '1234567',
  'info' => {
    'nickname' => 'jbloggs',
    'email' => 'joe@bloggs.com',
    'name' => 'Joe Bloggs',
    'first_name' => 'Joe',
    'last_name' => 'Bloggs',
    'image' => 'http://graph.facebook.com/1234567/picture?type=square',
    'urls' => { 'Facebook' => 'http://www.facebook.com/jbloggs' },
    'location' => 'Palo Alto, California',
    'verified' => true
  },
  'credentials' => {
    'token' => 'ABCDEF...',
    'expires_at' => 1321747205,
    'expires' => true
  },
  'extra' => {
    'raw_info' => {
      'id' => '1234567',
      'name' => 'Joe Bloggs',
      'first_name' => 'Joe',
      'last_name' => 'Bloggs',
      'link' => 'http://www.facebook.com/jbloggs',
      'username' => 'jbloggs',
      'location' => { 'id' => '123456789', 'name' => 'Palo Alto, California' },
      'gender' => 'male',
      'email' => 'joe@bloggs.com',
      'timezone' => -8,
      'locale' => 'en_US',
      'verified' => true,
      'updated_time' => '2011-11-11T06:21:03+0000'
    }
  }
}

def fast
  HASH.keys.map { |key| key.to_sym }
end

def slow
  HASH.map { |key, _val| key.to_sym }
end

def slower
  HASH.each_key.map { |key| key.to_sym }
end

Benchmark.ips do |x|
  x.report('Hash#keys.map')     { fast }
  x.report('Hash#map')          { slow }
  x.report('Hash#each_key.map') { slower }
  x.compare!
end