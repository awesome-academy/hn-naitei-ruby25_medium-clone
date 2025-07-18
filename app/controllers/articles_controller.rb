class ArticlesController < ApplicationController
  before_action :set_article, only: %i[ show edit update destroy ]
  before_action :authorize_modify, only: %i[edit update destroy]

  def show
    @comment = Comment.new
    @comments = @article.comments.includes(user: { avatar_attachment: :blob })
  end

  def edit
  end

  def create
    @user = current_user
    @article = @user.articles.build(article_params)

    respond_to do |format|
      if @article.save
        format.html { redirect_to profile_path(@user), notice: t("msg.create_article_success") }
        format.json { render :show, status: :created, location: @article }
      else
        format.html { redirect_to profile_path(@user), status: :unprocessable_entity }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @article.update(article_params)
        format.html { redirect_to @article, notice: t("msg.update_article_success") }
        format.json { render :show, status: :ok, location: @article }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if @article.destroy
      respond_to do |format|
        format.html { redirect_to articles_path, status: :see_other, notice: t("msg.delete_article_success") }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to articles_path, alert: t("msg.delete_article_failed") }
        format.json { render json: { errors: @article.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  private
    def set_article
      @article = Article.find_by(id: params[:id])
      return if @article

      redirect_to root_path, alert: t("msg.article_not_found")
    end

    def article_params
      params.require(:article).permit(Article::PERMITTED_ATTIBUTES)
    end

    def authorize_modify
      authorize! :modify, @article
    end
end
