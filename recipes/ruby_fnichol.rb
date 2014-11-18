node.force_default.rbenv.rubies = [
  '2.1.5',
]

include_recipe 'ruby_build::default'
include_recipe 'rbenv::system'
include_recipe 'rbenv::vagrant'
