module Api::V1
  class ArticlesController < ApiController
    skip_before_action :authenticate, only: [:index, :show]
    before_action :set_article, only: [:show, :update, :destroy]
    def index
      @articles = @article_q.result.recent
      render json: {
        data: {
          articles: @articles.as_json(
            include: {
              user: {
                only: [:username],
                include: :avatar
              }
            }
          )
        }
      }, status: :ok
    end

    def show
      render json: {
        data: {
          article: @article.as_json(
            include: {
              comments: {
                only: [:id, :content, :created_at],
                include: :user
              }
            }
          )
        },
        status: :success
      }, status: :ok
    end

    def create
      @article = @current_user.articles.build(article_params)

      if @article.save
        render json: @article, status: :created
      else
        render json: {errors: @article.errors.full_messages,
                      status: :error},
               status: :unprocessable_entity
      end
    end

    def update
      authorize! :modify, @article
      if @article.update(article_params)
        render json: {data: @article, status: :success}, status: :ok
      else
        render json: {errors: @article.errors.full_messages},
               status: :unprocessable_entity
      end
    end

    def destroy
      authorize! :modify, @article
      @article.destroy
      render json: {message: Settings.msg.article_deleted}, status: :ok
    end

    private
    def article_params
      params.require(:article).permit(Article::PERMITTED_ATTIBUTES)
    end

    def set_article
      @article = Article.find_by(id: params[:id])
      return if @article

      render json: {success: false, message: Settings.msg.record_not_found},
             status: :not_found
    end
  end
end
