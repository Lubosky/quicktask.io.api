module EmailUrlHelper
  PASSWORD_CHANGE_REQUEST_TEMPLATE = '/password/reset/{token}'.freeze

  private_constant :PASSWORD_CHANGE_REQUEST_TEMPLATE

  def build_url(method, **params)
    template = retrieve_template(method)
    UrlBuilder.new(template).expand(params)
  end

  private

  def retrieve_template(method)
    case method
    when :password_change_request then PASSWORD_CHANGE_REQUEST_TEMPLATE
    end
  end
end
