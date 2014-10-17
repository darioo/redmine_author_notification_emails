module AuthorNotificationEmails
  module Patches
    module MailerPatch
      unloadable

      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
        end
      end

      module InstanceMethods

        def mail(headers={}, &block)
          headers.merge! 'X-Mailer' => 'Redmine',
                         'X-Redmine-Host' => Setting.host_name,
                         'X-Redmine-Site' => Setting.app_title,
                         'X-Auto-Response-Suppress' => 'OOF',
                         'Auto-Submitted' => 'auto-generated',
                         'Sender' => Setting.mail_from,
                         'From' => ( @author && @author.logged? ) ? @author.mail : Setting.mail_from,
                         'Reply-To' => Setting.mail_from,
                         'List-Id' => "<#{Setting.mail_from.to_s.gsub('@', '.')}>"

          # Removes the author from the recipients and cc
          # if the author does not want to receive notifications
          # about what the author do
          if @author && @author.logged? && @author.pref.no_self_notified
            headers[:to].delete(@author.mail) if headers[:to].is_a?(Array)
            headers[:cc].delete(@author.mail) if headers[:cc].is_a?(Array)
            headers[:bcc].delete(@author.mail) if headers[:bcc].is_a?(Array)
          end

          if @author && @author.logged?
            #redmine_headers 'Sender' => @author.login # already done from super mail
            redmine_headers 'Sender-Email' => @author.mail
          end

          # Blind carbon copy recipients
          if Setting.bcc_recipients?
            headers[:bcc] = [headers[:to], headers[:bcc], headers[:cc]].flatten.uniq.reject(&:blank?)
            headers[:to] = nil
            headers[:cc] = nil
          end

          if @message_id_object
            headers[:message_id] = "<#{self.class.message_id_for(@message_id_object)}>"
          end
          if @references_objects
            headers[:references] = @references_objects.collect {|o| "<#{self.class.references_for(o)}>"}.join(' ')
          end

          m = if block_given?
                super headers, &block
              else
                super headers do |format|
              format.text
              format.html unless Setting.plain_text_mail?
            end
              end
          set_language_if_valid @initial_language

          m
        end
      end
    end
  end
end

require_dependency 'mailer'
Mailer.send(:include,  AuthorNotificationEmails::Patches::MailerPatch)
