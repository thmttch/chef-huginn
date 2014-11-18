user = node.huginn.user
group = node.huginn.group

install_dir = node.huginn.install_dir
repo_url = node.huginn.repo_url
repo_branch = node.huginn.repo_branch

db_name = node.huginn.db_name
db_user = node.huginn.db_user
db_pass = node.huginn.db_pass

git install_dir do
  repository repo_url
  reference repo_branch
  action :sync
  user user
  user group
end

template "#{install_dir}/.env" do
  source 'env.erb'
  owner user
  group group
  variables({
    db_name: db_name,
    db_user: db_user,
    db_pass: db_pass,
  })
end
