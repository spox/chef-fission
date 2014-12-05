fission_user 'fission'

include_recipe 'gpg'
include_recipe 'gpg::import'

ruby_block 'fission generator[set key]' do
  block do
    key_ref = node[:fission][:generator][:gpg_key]
    if(key_ref)
      key_id = [:gpg, :key_reference, key_ref, :private].inject(node) do |memo, k|
        memo[k] || break
      end
      if(key_id)
        result = Mash.new
        val = [:default_config, :instance, :fission, :repository_generator, :signing_key].inject(result) do |memo, k|
          memo[k] = Mash.new
        end
        val[:default] = key_id
        node.default[:fission] = Chef::Mixin::DeepMerge.merge(Mash.new(JSONCompat.from_json(JSONCompat.to_json(node[:fission]))), result)
      end
    end
  end
  action :nothing
  subscribes :create, 'gpg_import[packager]', :immediately
end