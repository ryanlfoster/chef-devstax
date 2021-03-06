return unless platform?("windows")
::Chef::Recipe.send(:include, Windows::Helper)

remote_iso_url = node['chef-devstax']['mssql']['2014']['iso']['url']
remote_iso_checksum = node['chef-devstax']['mssql']['2014']['iso']['checksum']
sapwd = node['chef-devstax']['mssql']['sapwd']

# get iso
local_iso = win_friendly_path(File.join(Chef::Config[:file_cache_path], 'mssql.iso'))
remote_file local_iso do
	source remote_iso_url
	checksum remote_iso_checksum
end

# get configuration ini
config_file = win_friendly_path(File.join(Dir.tmpdir(), 'ConfigurationFile.ini'))
template config_file do
	source "ConfigurationFile.ini.erb"
	variables({
		:params => {
			:sqlsysadminaccounts => "vagrant"
		}
	})
end

# get powershell scripts
ps_script_path = win_friendly_path(File.join(Dir.tmpdir(), 'scripts'))
remote_directory ps_script_path do
	source "scripts"
end

# execute install script
ps_module_path = win_friendly_path(File.join(ps_script_path, 'MSSQLUnattendedInstall'))
powershell_script "install_mssql" do
	cwd ps_script_path
	code <<-EOH
		Import-Module -Name #{ps_module_path}
		Install-MSSQL -ImagePath "#{local_iso}" -ConfigurationFile "#{config_file}" -SAPwd "#{sapwd}"
	EOH
end

# open firewall
chef_devstax_windows_firewall_rule "SQL Server" do
	port 1433
end

# clean up
file local_iso do
	action :delete
end
file config_file do
	action :delete
end