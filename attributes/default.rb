default.huginn = {
  user: 'huginn',
  group: 'huginn',
  home: '/home/huginn',

  install_dir: '/home/huginn/huginn',
  #repo_url: 'https://github.com/cantino/huginn.git',
  #repo_branch: 'master',
  repo_url: 'git://github.com/thmttch/huginn.git',
  repo_branch: 'thmttch',

  ruby_version: '2.1.5',

  db_name: 'huginn_dev',
  db_user: 'root',
  db_pass: node.mysql.server_root_password,
}
