class ApplicationController < ActionController::Base
  # ログイン前のリダイレクト先を設定
  before_action :store_location, unless: :devise_controller?

  protected

    def after_sign_up_path_for(resource)
      root_path
    end

    def after_sign_in_path_for(resource)
      stored_location_for(resource) || root_path
    end

    def after_sign_out_path_for(resource_or_scope)
      root_path
    end

  private

    def store_location
      # GET リクエストで、ログイン・登録ページ以外の場合のみ保存
      if request.get? && request.fullpath != new_user_session_path && request.fullpath != new_user_registration_path
        store_location_for(:user, request.fullpath)
      end
    end
end
