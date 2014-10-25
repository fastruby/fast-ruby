desc 'run benchmark in current ruby'
task :run_benchmark do
  [
    'code/general/assignment.rb',
    'code/general/begin-rescue-vs-respond-to.rb',
    'code/proc-and-block/block-vs-to_proc.rb',
    'code/proc-and-block/proc-call-vs-yield.rb',
    'code/enumerable/each-push-vs-map.rb',
    'code/enumerable/map-flatten-vs-flat_map.rb',
    'code/enumerable/reverse-each-vs-reverse_each.rb',
    'code/enumerable/sort-vs-sort_by.rb',
    'code/array/each_with_index-vs-while-loop.rb',
    'code/array/shuffle-first-vs-sample.rb',
    'code/hash/fetch-vs-fetch-with-block.rb',
    'code/hash/keys-each-vs-each_key.rb',
    'code/hash/merge-bang-vs-[]=.rb',
    'code/hash/merge-vs-merge-bang.rb',
    'code/string/casecmp-vs-downcase-==.rb',
    'code/string/concatenation.rb',
    'code/string/end-string-checking-match-vs-start_with.rb',
    'code/string/gsub-vs-sub.rb',
    'code/string/gsub-vs-tr.rb',
    'code/string/start-string-checking-match-vs-start_with.rb'
  ].each do |benchmark|
    puts "$ ruby -v #{benchmark}"
    system('ruby', '-v', benchmark)
  end
end

task default: :run_benchmark
