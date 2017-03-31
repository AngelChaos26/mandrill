module Spree

  require "mandrill"

  class UserMailerMandrill < BaseMailer


    def reset_password_instructions(user, token, *args)
      @store = Spree::Store.default
      @edit_password_reset_url = spree.edit_spree_user_password_url(reset_password_token: token, host: @store.url)
      
       merge_vars = {
        "FIRST_NAME" => user.first_name,
        "USER_URL" => user.first_name
      }

      body = mandrill_template("reset_user_password", merge_vars)

      mail to: user.email, body: body,content_type: "text/html", from:"Wedjourney <contact@wedjourney.com>", subject: "#{@store.name} #{I18n.t(:subject, scope: [:devise, :mailer, :reset_password_instructions])}"
    end

    def confirmation_instructions(user, token, opts={})
      @store = Spree::Store.default
      @confirmation_url = spree.spree_user_confirmation_url(confirmation_token: token, host: @store.url)

      merge_vars = {
        "FIRST_NAME" => user.first_name,
        "USER_URL" => @confirmation_url,
      }

      body = mandrill_template("confirm_user", merge_vars)

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
