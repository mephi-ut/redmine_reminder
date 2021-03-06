module Reminder
  module IssuePatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        # Same as typing in the class.
        unloadable # Send unloadable so it will not be unloaded in development.
        safe_attributes 'reminder_notification'
        validates_format_of :reminder_notification, :with => /\A\s*(\d+(\s*,\s*\d+)*)?\z/, :on => :update
      end
    end
  end

  module InstanceMethods

    def reminder_notification_array
      unless reminder_notification.blank?
        return reminder_notification.split(%r{[\s,\s]}).collect(&:to_i).uniq.select { |n| n >= 0 }.sort
      end
      []
    end

    def days_before_start_date
      return 365 * 100 if start_date.nil?
      return (start_date - Date.today).to_i
    end

    def days_before_due_date
      return 365 * 100 if due_date.nil?
      return (due_date - Date.today).to_i
    end

    def remind_due_date?
      return false unless project.module_enabled?(:reminder_notifications)
      if assigned_to.present?
        if reminder_notification_array.any? then
          return reminder_notification_array.include?(days_before_due_date)
        elsif category.present? && category.reminder_notification_array.any? then
          return category.reminder_notification_array.include?(days_before_due_date)
        else
          return assigned_to.reminder_notification_array.include?(days_before_due_date)
        end
      end
      return false
    end

    def remind_start_date?
      return false unless project.module_enabled?(:reminder_notifications)
      if assigned_to.present?
        if reminder_notification_array.any? then
          return reminder_notification_array.include?(days_before_start_date)
        elsif category.present? && category.reminder_notification_array.any? then
          return category.reminder_notification_array.include?(days_before_start_date)
        else
          return assigned_to.reminder_notification_array.include?(days_before_start_date)
        end
      end
      return false
    end
  end
end
