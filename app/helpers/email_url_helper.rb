module EmailUrlHelper
  CONFIRM_SIGNUP_TEMPLATE = '/signup/confirm/{token}'.freeze
  PASSWORD_CHANGE_REQUEST_TEMPLATE = '/password/reset/{token}'.freeze

  private_constant :CONFIRM_SIGNUP_TEMPLATE
  private_constant :PASSWORD_CHANGE_REQUEST_TEMPLATE

  def build_url(method, **params)
    template = retrieve_template(method)
    UrlBuilder.new(template).expand(params)
  end

  private

  def retrieve_template(method)
    case method
    when :confirm_signup then CONFIRM_SIGNUP_TEMPLATE
    when :password_change_request then PASSWORD_CHANGE_REQUEST_TEMPLATE
    end
  end
end
