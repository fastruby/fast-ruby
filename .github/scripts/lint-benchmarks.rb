# Checks that every benchmark under code/ has the same shape, so they all run,
# print a comparison, and are measured the same way:
#
# - every Benchmark.ips block calls x.compare!
# - no custom timing (Benchmark.ips(20), x.time = 20, x.warmup = 5, x.config(time: 20) in any hash syntax),
#   so every file uses the default
# - no Benchmark.ips sits inside a method that never runs from the top of the file,
#   which would benchmark nothing at all
# - every Benchmark.ips block states which report should win: exactly one
#   report calls `fastest` (else `faster`, else `fast`), and it comes first
#
# Usage: ruby .github/scripts/lint-benchmarks.rb [files...]  (needs Ruby 3.3+)
require "prism"

# Calls named `name`, not looking inside the ones found. Only calls with a
# block, unless `with_block: false` (reports can be a code string: x.report(label, code)).
def find_calls(node, name, with_block: true, found: [])
  return found unless node

  if node.is_a?(Prism::CallNode) && node.name == name && (node.block || !with_block)
    found << node
  else
    node.compact_child_nodes.each { |child| find_calls(child, name, with_block: with_block, found: found) }
  end
  found
end

def any_call?(node, &test)
  return false unless node
  return true if node.is_a?(Prism::CallNode) && test.call(node)

  node.compact_child_nodes.any? { |child| any_call?(child, &test) }
end

CLAIM_METHODS = %i[fastest faster fast].freeze

# Method names called under `node` without a receiver.
def called_names(node, names = [])
  return names unless node

  names << node.name if node.is_a?(Prism::CallNode) && node.receiver.nil?
  node.compact_child_nodes.each { |child| called_names(child, names) }
  names
end

def claim_problem(ips)
  reports = find_calls(ips.block, :report, with_block: false).map { |r| called_names(r.block) }
  top = CLAIM_METHODS.find { |name| reports.any? { |calls| calls.include?(name) } }
  return "no claim. Wrap each report in a method and name the winner's `fast` (or `faster`, `fastest`)" unless top

  claimed = reports.count { |calls| calls.include?(top) }
  return "#{claimed} reports call `#{top}`. Name only the winner `#{top}`" if claimed > 1

  "the report calling `#{top}` must come first" unless reports.first.include?(top)
end

TIMING_KEYS = %w[time warmup].freeze

# x.time = 20, x.warmup = 5, or x.config with a time or warmup key,
# in any hash syntax (time: 20, :time => 20).
def sets_timing?(node)
  any_call?(node) do |call|
    next true if %i[time= warmup=].include?(call.name)
    next false unless call.name == :config && call.arguments

    call.arguments.arguments.any? do |arg|
      next false unless arg.is_a?(Prism::KeywordHashNode) || arg.is_a?(Prism::HashNode)

      arg.elements.any? do |element|
        element.is_a?(Prism::AssocNode) && element.key.is_a?(Prism::SymbolNode) &&
          TIMING_KEYS.include?(element.key.unescaped)
      end
    end
  end
end

# Every method is known by its name, and by its scope
# ("Foo#run", or "#run" at the top of the file).
# A class method is also known by its full class name ("A::B.run"),
# whether defined as `def self.run` or inside `class << self`,
# so a call like `A.run` does not count as calling `C.run`.
Definition = Struct.new(:keys, :node, :owner)

def nested_name(owner, node)
  [owner, node.constant_path.slice].compact.join("::")
end

def definitions(node, owner = nil, singleton = false, found = [])
  return found unless node

  case node
  when Prism::ClassNode, Prism::ModuleNode
    owner = nested_name(owner, node)
    singleton = false
  when Prism::SingletonClassNode
    singleton = node.expression.is_a?(Prism::SelfNode)
  when Prism::DefNode
    class_method = owner && (singleton || node.receiver.is_a?(Prism::SelfNode))
    keys = [node.name.to_s, "#{owner}##{node.name}"]
    keys << "#{owner}.#{node.name}" if class_method
    found << Definition.new(keys, node, owner)
  end
  node.compact_child_nodes.each { |child| definitions(child, owner, singleton, found) }
  found
end

# Keys a call can reach:
# - a call without a receiver reaches a method in the same class or at the
#   top of the file when the file defines one, otherwise any method of that
#   name (one from a parent class or an included module);
# - `Foo.run` reaches "Foo.run" when the file defines it, otherwise any `run`;
# - a call on another object (`Foo.new.run`) reaches any `run`;
# - calls on a variable (x.report, x.compare!) are the benchmark's own API.
def keys_of(call, owner, known)
  receiver = call.receiver
  case receiver
  when Prism::LocalVariableReadNode
    []
  when nil, Prism::SelfNode
    scoped = ["##{call.name}", *("#{owner}##{call.name}" if owner)]
    scoped.intersect?(known) ? scoped : [call.name.to_s]
  when Prism::ConstantReadNode, Prism::ConstantPathNode
    key = "#{receiver.slice}.#{call.name}"
    known.include?(key) ? [key] : [call.name.to_s]
  else
    [call.name.to_s]
  end
end

# Keys of the methods called anywhere under `node`, from code in class
# `owner`. With `top_level: true`, only calls outside any method:
# the file's entry points.
def called_keys(node, known, owner: nil, top_level: false, keys: [])
  return keys unless node
  return keys if top_level && node.is_a?(Prism::DefNode)

  owner = nested_name(owner, node) if node.is_a?(Prism::ClassNode) || node.is_a?(Prism::ModuleNode)
  keys.concat(keys_of(node, owner, known)) if node.is_a?(Prism::CallNode)
  node.compact_child_nodes.each do |child|
    called_keys(child, known, owner: owner, top_level: top_level, keys: keys)
  end
  keys
end

# Methods that run when the file runs: called from top-level code, or from a method that does.
def reachable_methods(root, methods)
  known = methods.flat_map { |m| m.keys.drop(1) }
  keys = called_keys(root, known, top_level: true)
  reached = []
  loop do
    newly = (methods - reached).select { |m| m.keys.intersect?(keys) }
    break if newly.empty?

    reached.concat(newly)
    newly.each { |m| keys.concat(called_keys(m.node.body, known, owner: m.owner)) }
  end
  reached
end

def lint(file)
  result = Prism.parse_file(file)
  return ["does not parse: #{result.errors.first.message}"] if result.failure?

  blocks = find_calls(result.value, :ips)
  return ["no Benchmark.ips block"] if blocks.empty?

  methods = definitions(result.value)
  reached = reachable_methods(result.value, methods)
  problems = []

  blocks.each_with_index do |ips, index|
    where = blocks.size > 1 ? "block #{index + 1} (line #{ips.location.start_line})" : "Benchmark.ips"

    problems << "#{where}: no x.compare!" unless any_call?(ips.block) { |call| call.name == :compare! }
    problems << "#{where}: remove the timing arguments, use the default" if ips.arguments
    problems << "#{where}: remove the timing settings, use the default" if sets_timing?(ips.block)

    # The innermost method around this Benchmark.ips, if any.
    owner = methods.select do |m|
      m.node.location.start_offset <= ips.location.start_offset && ips.location.end_offset <= m.node.location.end_offset
    end.min_by { |m| m.node.location.length }

    if owner && !reached.include?(owner)
      name = owner.keys.last.delete_prefix("#")
      problems << "#{where}: inside `def #{name}`, which never runs from the top of the file"
    end

    claim = claim_problem(ips)
    problems << "#{where}: #{claim}" if claim
  end
  problems
end

files = ARGV.empty? ? Dir["code/**/*.rb"].sort : ARGV
problems = files.flat_map { |file| lint(file).map { |problem| "#{file}: #{problem}" } }

if problems.empty?
  puts "All #{files.size} benchmark files have the expected shape."
else
  noun = problems.size == 1 ? "problem" : "problems"
  puts problems, "", "#{problems.size} #{noun}, see \"Note on entry\" in CONTRIBUTING.md."
  exit 1
end
