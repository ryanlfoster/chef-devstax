return unless platform?("windows")
::Chef::Recipe.send(:include, Windows::Helper)

remote_iso_url = node['chef-devstax']['visualstudio']['2013']['ultimate']['iso']['url']
remote_iso_checksum = node['chef-devstax']['visualstudio']['2013']['ultimate']['iso']['checksum']

# get iso
local_iso = win_friendly_path(File.join(Chef::Config[:file_cache_path], 'visualstudio.iso'))
remote_file local_iso do
	source remote_iso_url
	checksum remote_iso_checksum
end

# get deployment xml
config_file = win_friendly_path(File.join(Dir.tmpdir(), 'AdminDeployment.xml'))
template config_file do
	source "AdminDeployment.xml.erb"
	variables({
		:features => {
			:blend => "no",
			:lightswitch => "no",
			:vc_mfc_libraries => "no",
			:officedevelopertools => "no",
			:sql => "yes",
			:webtools => "yes",
			:win8sdk => "no",
			:silverlight_developer_kit => "no",
			:windowsphone80 => "no"
		}
	})
end

# get powershell scripts
ps_script_path = win_friendly_path(File.join(Dir.tmpdir(), 'scripts'))
remote_directory ps_script_path do
	source "scripts"
end

# execute install script
ps_module_path = win_friendly_path(File.join(ps_script_path, 'VisualStudioUnattendedInstall'))
powershell_script "install_visual_studio" do
	cwd ps_script_path
	code <<-EOH
		Import-Module -Name #{ps_module_path}
		Install-VisualStudio -ImagePath "#{local_iso}" -AdminFile "#{config_file}"
	EOH
end

file local_iso do
	action :delete
end
file config_file do
	action :delete
end