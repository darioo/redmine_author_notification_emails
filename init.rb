require 'redmine'

require_dependency 'author_notification_emails/patches/mailer_patch'

Redmine::Plugin.register :redmine_author_notification_emails do
  
  name 'Redmine Author Notification Emails'
  author 'Dariusz Kowalski'
  description 'This plugin change FROM adres at all Emails to Logged User email'
  version '1.0.0' 
  author_url 'https://github.com/darioo'
  url "https://github.com/darioo/redmine_author_notification_emails" if respond_to?(:url)
end
