require 'benchmark/ips'

ints = [*1..100]
int_samples = (ints + ints.map(&100.method(:-)))

floats = ints.map(&:to_f)
float_samples = int_samples.map(&:to_f)

bools = [true, false, nil]

strs = ints.map(&:to_s)
strs_samples = int_samples.map(&:to_s)

syms = ints.map(&:to_s).map(&:to_sym),
sym_samples = int_samples.map(&:to_s).map(&:to_sym)

to_obj = -> (index) { { index => ints.sample } }

objs = ints.map(&to_obj)
obj_samples = int_samples.map(&to_obj)

to_arr = -> (index) { [index] }

arrs = ints.map(&to_arr)
arr_samples = int_samples.map(&to_arr)

all = [1, -100, true, false, 'some', {}, [], 1.5, nil, TrueClass, 0, :test]
all_samples = all + [2, 3, 4, 'test', :new, [1], FalseClass]

Benchmark.ips do |x|
  x.report('Array#include?(all)') { all.include?(all_samples.sample) }
  x.report('Array#index(all)') { all.index(all_samples.sample) }

  x.report('Array#include?(bool)') { bools.include?(bools.sample) }
  x.report('Array#index(bool)') { bools.index(bools.sample) }

  x.report('Array#include?(float)') { floats.include?(float_samples.sample) }
  x.report('Array#index(float)') { floats.index(float_samples.sample) }

  x.report('Array#include?(int)') { ints.include?(int_samples.sample) }
  x.report('Array#index(int)') { ints.index(int_samples.sample) }

  x.report('Array#include?(objs)') { objs.include?(obj_samples.sample) }
  x.report('Array#index(objs)') { objs.index(obj_samples.sample) }

  x.report('Array#include?(str)') { strs.include?(strs_samples.sample) }
  x.report('Array#index(str)') { strs.index(strs_samples.sample) }

  x.report('Array#include?(syms)') { syms.include?(sym_samples.sample) }
  x.report('Array#index(syms)') { syms.index(sym_samples.sample) }

  x.report('Array#include?(arrs)') { arrs.include?(arr_samples.sample) }
  x.report('Array#index(arrs)') { arrs.index(arr_samples.sample) }

  x.compare!
end
