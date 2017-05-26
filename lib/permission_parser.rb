class PermissionParser
  PERMISSION_LIST_FILENAME = 'permissions.json'

  class << self

    def create
      File.delete(PERMISSION_LIST_FILENAME) if File.exist?(PERMISSION_LIST_FILENAME)

      policies = Dir.entries(Rails.root.join('app', 'policies')).reject{
          |file| %w(. .. admin_policy.rb base_policy.rb provider_policy.rb).include? file
      }.map{ |file| File.basename(file, '.rb').camelcase }

      permissions = []

      policies.each do |policy|
        methods = policy.constantize.instance_methods(false)
        methods.each do |method|
          permissions << { "#{policy.underscore.gsub('_policy', '').humanize} #{method.to_s.humanize(capitalize: false)}" => "#{policy}##{method}" }
        end
      end
      File.open(PERMISSION_LIST_FILENAME, 'w') do |f|
        f.write(permissions.to_json)
      end
    end

    def set_default(provider)
      if provider.present?
        permissions = JSON.parse(File.read(PERMISSION_LIST_FILENAME))
        permission_ids = Permission.insert_all(permission_attrs(permissions, provider.id))
        Availability.insert_all(availibility_attrs(permission_ids))
      end
    end

    # run PermissionParser.reload if you add new policy or change something
    # WARNING! This method will set all permissions to default
    def reload
      create
      Permission.destroy_all
      Provider.where(practice_role: :Provider).each { |provider| set_default(provider) }
    end

    private

    def permission_attrs(permissions, provider_id)
      permissions.map { |p| { presentation: p.keys[0],
                              policy_name: p.values[0],
                              provider_id: provider_id } }
    end

    def availibility_attrs(permission_ids)
      practice_roles = [:Admin] + Provider.practice_roles - [:Provider]
      permission_ids.map { |permission_id| practice_roles.map { |role| { role: role,
                                                                         available: true,
                                                                         permission_id: permission_id } } }.flatten
    end
  end
end
