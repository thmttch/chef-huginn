user = node.huginn.user
install_dir = node.huginn.install_dir
ruby_version = node.huginn.ruby_version

foreman_path = "/opt/rbenv/versions/#{ruby_version}/bin/foreman"

include_recipe 'runit::default'
runit_service 'huginn' do
  options({
    install_dir: install_dir,
    user: user,
    foreman_path: foreman_path,
  })
  env({
    'RBENV_ROOT' => '/opt/rbenv',
  })
  default_logger true
  sv_verbose true
  action [ :enable, :start ]
end
