module EmailUrlHelper
  CONFIRM_SIGNUP_TEMPLATE = '/signup/confirm/{token}'.freeze
  PASSWORD_CHANGE_REQUEST_TEMPLATE = '/password/reset/{token}'.freeze
  HAND_OFF_ASSIGNMENT_TEMPLATE = '/request/assignment/{token}'.freeze
  HAND_OFF_INVITATION_TEMPLATE = '/request/review/{token}'.freeze

  private_constant :CONFIRM_SIGNUP_TEMPLATE
  private_constant :PASSWORD_CHANGE_REQUEST_TEMPLATE
  private_constant :HAND_OFF_ASSIGNMENT_TEMPLATE
  private_constant :HAND_OFF_INVITATION_TEMPLATE

  def build_url(method, **params)
    template = retrieve_template(method)
    UrlBuilder.new(template).expand(params)
  end

  private

  def retrieve_template(method)
    case method
    when :confirm_signup then CONFIRM_SIGNUP_TEMPLATE
    when :password_change_request then PASSWORD_CHANGE_REQUEST_TEMPLATE
    when :hand_off_assignment then HAND_OFF_ASSIGNMENT_TEMPLATE
    when :hand_off_invitation then HAND_OFF_INVITATION_TEMPLATE
    end
  end
end
