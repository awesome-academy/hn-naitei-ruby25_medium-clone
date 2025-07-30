class ArticlesController < ApplicationController
  load_and_authorize_resource
  before_action :authenticate_user!, except: %i(show)

  def show
    @comment = Comment.new
    @comments = @article.comments.includes(user: {avatar_attachment: :blob})
                        .first_level
  end

  def edit; end

  def create
    @user = current_user
    @article = @user.articles.build(article_params)

    respond_to do |format|
      if @article.save
        format.html do
          redirect_to profile_path(@user),
                      notice: t("msg.create_article_success")
        end
        format.json{render :show, status: :created, location: @article}
      else
        format.html do
          redirect_to profile_path(@user),
                      status: :unprocessable_entity
        end
        format.json do
          render json: @article.errors, status: :unprocessable_entity
        end
      end
    end
  end

  def update
    respond_to do |format|
      if @article.update(article_params)
        format.html do
          redirect_to @article,
                      notice: t("msg.update_article_success")
        end
        format.json{render :show, status: :ok, location: @article}
      else
        format.html{render :edit, status: :unprocessable_entity}
        format.json do
          render json: @article.errors, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    if @article.destroy
      respond_to do |format|
        format.html do
          redirect_to profile_path(current_user), status: :see_other,
                      notice: t("msg.delete_article_success")
        end
        format.json{head :no_content}
      end
    else
      respond_to do |format|
        format.html do
          redirect_to profile_path(current_user),
                      alert: t("msg.delete_article_failed")
        end
        format.json do
          render json: {errors: @article.errors.full_messages},
                 status: :unprocessable_entity
        end
      end
    end
  end

  private
  def article_params
    params.require(:article).permit(Article::PERMITTED_ATTIBUTES)
  end
end
