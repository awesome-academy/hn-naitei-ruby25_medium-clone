class CommentsController < ApplicationController
  before_action :set_article
  before_action :set_comment, only: [ :edit, :update, :destroy ]

  def create
    @new_comment = @article.comments.build(comment_params)
    @new_comment.user = current_user

    if @new_comment.save
      @comment = @article.comments.build
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to request.referer }
      end
    else
      render turbo_stream: turbo_stream.replace(
        "new_comment",
        partial: "comments/form"
      )
    end
  end

  def edit
    respond_to do |format|
      format.turbo_stream
      format.html do
        render partial: "comments/form"
      end
    end
  end

  def update
    if @comment.update(comment_params)
      flash[:notice] = t "msg.comment_updated"
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to article_path(@article) }
      end
    else
      flash[:alert] = t "msg.update_comment_failed"
      redirect_to article_path(@article)
    end
  end


  def destroy
    @article = @comment.article
    if @comment.destroy
      flash[:notice] = t "msg.comment_deleted"
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove("comment_#{@comment.id}") }
        format.html { redirect_to article_path(@article) }
      end
    else
      flash[:alert] = t "msg.delete_comment_failed"
      redirect_to request.referer || root_path
    end
  end

  private
  def comment_params
    params.require(:comment).permit(Comment::PERMMIT_PARAMS)
  end

  def set_article
    @article = Article.find_by(id: params[:article_id])
    return if @article.present?

    flash[:alert] = t "msg.article_not_found"
    redirect_to root_path
  end

  def set_comment
    @comment = Comment.find_by(id: params[:id])
    return if @comment

    flash[:alert] = t "msg.comment_not_found"
    redirect_to request.referer || root_path
  end
end
