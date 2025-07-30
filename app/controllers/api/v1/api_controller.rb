module Api::V1
  class ApiController < ApplicationController
    include CanCan::ControllerAdditions

    skip_before_action :verify_authenticity_token
    skip_before_action :set_ransack_query
    before_action :authenticate
    before_action :initialize_api_ransack_query

    attr_reader :current_user

    rescue_from CanCan::AccessDenied do
      render json: {status: :error, message: Settings.msg.action_not_allowed},
             status: :forbidden
    end

    private
    def authenticate
      access_token = request.headers["Authorization"]
      unless access_token
        return render json: {success: false,
                             message: Settings.access_token_notfound},
                      status: :unauthorized
      end

      @decoded = JsonWebToken.decode access_token&.split(" ")&.last
      if @decoded[:type] == "access"
        @current_user = User.find_by(id: @decoded[:user_id])
      end
      return if @current_user

      render json: {success: false,
                    message: Settings.msg.invalid_access_token,
                    data: nil},
             status: :unauthorized
    end

    def initialize_api_ransack_query
      @article_q = Article.ransack(params[:article_q])
      @profile_q = User.ransack(params[:profile_q])
    end
  end
end
