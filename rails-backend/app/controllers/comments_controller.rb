# frozen_string_literal: true
require "text_captcha"
class CommentsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :create, :captcha]
  before_action :find_article!, except: [:captcha]
  

  def captcha
    item = TextCaptcha.get
    render json: item
  end

  def index
    @comments = @article.comments.order(created_at: :desc)
  end


  def create
    unless signed_in?
      captcha_params = params.require(:comment).permit(:captcha_key, :captcha_answer)
      captcha_key = captcha_params[:captcha_key]
      captcha_answer = captcha_params[:captcha_answer]
      
      unless TextCaptcha.valid_answer?(captcha_key, captcha_answer)
        render json: { errors: { captcha: ['could not validate captcha'] } }, status: :forbidden and return
      end
    end

    @comment = @article.comments.new(comment_params)
    @comment.user = current_user if signed_in?
    
    render json: { errors: @comment.errors }, status: :unprocessable_entity unless @comment.save 
  end

  def destroy
    @comment = @article.comments.find(params[:id])

    if @comment.user_id == @current_user_id
      @comment.destroy
      render json: {}
    else
      render json: { errors: { comment: ['not owned by user'] } }, status: :forbidden
    end
  end

  private


  def comment_params
    params.require(:comment).permit(:body)
  end

  def find_article!
    @article = Article.find_by!(slug: params[:article_slug])
  end
end
