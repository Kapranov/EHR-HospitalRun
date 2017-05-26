module Provider::Activatable
  def activate
    DoubleNotifier.notify(user, 'activated') if update(active: true)
  end

  def deactivate
    DoubleNotifier.notify(user, 'deactivated') if update(active: false)
  end
end