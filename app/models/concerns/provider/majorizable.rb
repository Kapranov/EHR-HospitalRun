module Provider::Majorizable

  def main_provider?
    practice_role == :Provider
  end

  def main_provider
    main_provider? ? self : provider
  end

  def all_providers
    main_provider.providers.to_a.dup << main_provider
  end

  def find_provider(id)
    all_providers.find { |provider| provider.id == id }
  end

  def find_providers_by(part)
    all_providers.find_all{ |p| p.first_name =~ /^#{part}/ || p.last_name =~ /^#{part}/ }
  end

  def providers_first(amount = 10)
    all_providers.first(amount)
  end
end