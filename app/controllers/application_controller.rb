class ApplicationController < ActionController::Base

  protect_from_forgery
  before_filter :set_locale

  helper_method :after_sign_in_path_for

  # pick the locale from ?locale=X in the url,  a prettier
  # solution might be used down the line, maybe depending
  # on the ui or user preferences maybe.
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  # maintain the locale param on any urls
  def default_url_options(options={})
    # { :locale => I18n.locale }
    {}
  end

  def after_sign_in_path_for(resource)
    # If the user has a survey stored in their session, assign it to them and redirect to the survey,
    # deleting the session id even if the response set isn't found
    case
      when session[:response_set_id] && response_set = ResponseSet.find(session.delete(:response_set_id))
        # Assign the response set to the user, creating a dataset for it
        response_set.assign_to_user!(current_user)

        if params[:form_id] == 'save_and_finish_modal_form'
          # if the user has authenticated from the save_and_finish_modal_form then redirect to the force_save_questionnaire path
          surveyor.force_save_questionnaire_path(:survey_code => response_set.survey.access_code, :response_set_code => response_set.access_code)
        else
          surveyor.edit_my_survey_path(
            :survey_code => response_set.survey.access_code,
            :response_set_code => response_set.access_code
          )
        end

      when params[:form_id] == 'start_cert_modal_form'
        # if the user has authenticated from the start_cert_modal_form then redirect to the start_questionnaire path
        authenticated_start_questionnaire_path

      when session[:sign_in_redirect]
        # a sign in path was set at some point
        session.delete(:sign_in_redirect)

      else
        dashboard_path
    end
  end

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from CanCan::AccessDenied, with: :not_authorised

  protected
  def parse_iso8601(value)
    case value.strip
    when /^\d{4}$/
      DateTime.new(value.to_i)
    when /^\d{4}-?\d{2}$/
      h, m = /(\d{4})-?(\d{2})/.match(value)[1,2]
      DateTime.new(h.to_i, m.to_i)
    else
      DateTime.iso8601(value)
    end
  end

  private

  def authenticate_user_from_token!
    user = authenticate_with_http_basic do |email, token|
      user = User.find_by_email(email)
      if user && Devise.secure_compare(user.authentication_token, token)
        user
      end
    end

    if user
      sign_in user, store: false
    else
      request_http_basic_authentication
    end
  end

  def current_ability
    @current_ability ||= Hash.new { |h, k| Ability.new(k) }
    @current_ability[current_user]
  end

  # display 404 when we can't find a record
  def record_not_found
    render :file => Rails.root.join('public','404.html'), :status => "404 Not Found", layout: false
  end

  def not_authorised
    render :file => Rails.root.join('public','403.html'), :status => 403, layout: false
  end

end
