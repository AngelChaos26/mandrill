module Spree
  require "mandrill"
  class UserMailerMandrill < BaseMailer
    def reset_password_instructions(user, token, *args)
      @store = Spree::Store.default
      @edit_password_reset_url = spree.edit_spree_user_password_url(reset_password_token: token, host: @store.url)
      current_date = Date.current
      
      if user.isTransfer.nil?
         @edit_password_reset_url += "&is_trans=0"
      else
         @edit_password_reset_url += "&is_trans=1"
      end
      
      merge_vars = {
        "USER_NAME" => user.first_name.to_s.capitalize,
        "DATE" => current_date.day.to_s + "/" + current_date.month.to_s + "/" + current_date.year.to_s,
        "EMAIL" => user.email,
        "USER_URL" =>  @edit_password_reset_url,
        "LOCALE" => user.default_language.to_s.downcase
      }
      
      body = mandrill_template("change-settings-password-reset", merge_vars) #reset_user_password old template

      mail to: user.email, body: body,content_type: "text/html", from:"Wedjourney <contact@wedjourney.com>", subject: "#{@store.name} #{I18n.t(:subject, scope: [:devise, :mailer, :reset_password_instructions])}"
    end

    def confirmation_instructions(user, token, opts={})
      @store = Spree::Store.default
      @confirmation_url = spree.spree_user_confirmation_url(confirmation_token: token, host: @store.url)

      merge_vars = {
        "USER_URL" => @confirmation_url,
        "LOCALE" => user.default_language.to_s.downcase
      }

      body = mandrill_template("account-creation", merge_vars) #confirm_user old template

      mail to: user.email, body: body, content_type: "text/html", from:"Wedjourney <contact@wedjourney.com>", subject: "#{@store.name} #{I18n.t(:subject, scope: [:devise, :mailer, :confirmation_instructions])}"
    end


    private 
    def mandrill_template(template_name, attributes)
      mandrill = Mandrill::API.new(ENV["SMTP_PASSWORD"])

      merge_vars = attributes.map do |key, value|
        { name: key, content: value }
      end

      mandrill.templates.render(template_name, [], merge_vars)["html"]
    end


  end
end
