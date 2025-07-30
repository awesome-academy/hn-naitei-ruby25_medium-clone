class CommentsController < ApplicationController
  load_and_authorize_resource :article
  load_and_authorize_resource :comment, through: :article
  before_action :authenticate_user!

  def create
    @new_comment = @article.comments.build(comment_params)
    @new_comment.user = current_user

    if @new_comment.save
      @comment = @article.comments.build
      send_notification_to_author if current_user.id != @article.user.id
      respond_to do |format|
        format.turbo_stream
        format.html{redirect_to request.referer}
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
        format.html{redirect_to article_path(@article)}
      end
    else
      flash[:alert] = t "msg.update_comment_failed"
      redirect_to article_path(@article)
    end
  end

  def destroy
    @article = @comment.article
    if @comment.destroy
      handle_successful_destroy
    else
      flash[:alert] = t("msg.delete_comment_failed")
      redirect_to article_path(@article)
    end
  end

  def new_reply
    @new_comment = @article.comments.build(parent_id: @comment.id)

    respond_to do |format|
      format.turbo_stream
    end
  end

  def create_reply
    @new_comment = @article.comments.build(comment_params)
    @new_comment.user = current_user
    @new_comment.parent_id = @comment.id

    if @new_comment.save
      respond_to do |format|
        format.turbo_stream
        format.html{redirect_to article_path(@article)}
      end
    else
      flash[:alert] = t "msg.reply_failed"
      redirect_to article_path(@article)
    end
  end

  private
  def comment_params
    params.require(:comment).permit(Comment::PERMIT_PARAMS)
  end

  def handle_successful_destroy
    flash[:notice] = t("msg.comment_deleted")
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove("comment_form_#{@comment.id}")
      end
      format.html{redirect_to article_path(@article)}
    end
  end

  def send_notification_to_author
    UserNotiJob.perform_async(
      @article.user.id,
      t("notification.new_comment", article: @article.title),
      "Comment",
      @new_comment.id
    )
  end
end
