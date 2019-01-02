SimpleCov.start do
  add_filter '/spec/'

  add_group 'Commands', 'lib/commands'
  add_group 'Models', 'lib/db'
  add_group 'Parsers', 'lib/parser'

  minimum_coverage 90
end
