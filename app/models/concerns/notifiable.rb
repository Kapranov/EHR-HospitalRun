module Notifiable
  def self.included(base)
    base.class_eval do
      after_create  :notify_admin_on_create
      after_destroy :notify_admin_on_destroy
    end
  end

  def notify_admin_on_create
    AdminNotifier.notify_admin("New #{target_class_name} #{full_name} was created")
  end

  def notify_admin_on_destroy
    AdminNotifier.notify_admin("#{target_class_name.capitalize} #{full_name} was destroyed")
  end

  private

  def target_class_name
    self.class.name.downcase
  end
end