# frozen_string_literal: true

require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  include FactoryBot::Syntax::Methods

  # index

  test "getting comments of article" do
    article = create(:article, slug: "some-slug")
    create(:comment, article: article, body: "Some comment")

    get(article_comments_url(article_slug: "some-slug"))
    json = JSON.parse(response.body)

    assert_equal "Some comment", json.dig("comments", 0, "body")
    assert_response :success
  end

  # create

  test "creating new comment succeeds as authorized user" do
    user = create(:user)
    create(:article, slug: "some-slug")

    assert_changes -> { user.comments.count } do
      post(article_comments_url(article_slug: "some-slug"),
           headers: authorization_headers_for(user),
           params: {
             comment: {
               body: "My comment"
             }
           })
    end

    assert_response :success
  end

  test "creating new comment succeeds as anonymous user with valid captcha" do
    article = create(:article, slug: "some-slug")

    assert_changes -> { article.comments.count } do
      post(article_comments_url(article_slug: "some-slug"),
           params: {
             comment: {
               body: "My comment",
               captcha_key: 1,
               captcha_answer: "red"
             }
           })
    end

    assert_response :success
  end

  test "creating new comment succeeds as anonymous user with invalid captcha" do
    article = create(:article, slug: "some-slug")

    assert_no_changes -> { article.comments.count } do
      post(article_comments_url(article_slug: "some-slug"),
           params: {
             comment: {
               body: "My comment",
               captcha_key: 1,
               captcha_answer: "2"
             }
           })
    end

    assert_response :forbidden
  end

  # destroy

  test "deleting own comment succeeds for authorized user" do
    user = create(:user)
    article = create(:article, slug: "some-slug")
    comment = create(:comment, user: user, article: article)

    assert_changes -> { article.comments.count } do
      delete(article_comment_url(article_slug: "some-slug", id: comment.id),
             headers: authorization_headers_for(user))
    end

    assert_response :success
  end

  test "deleting other user's comment is forbidden as authorized user" do
    user = create(:user)
    other_user = create(:user)
    article = create(:article, slug: "some-slug")
    comment = create(:comment, user: other_user, article: article)

    assert_no_changes -> { article.comments.count } do
      delete(article_comment_url(article_slug: "some-slug", id: comment.id),
             headers: authorization_headers_for(user))
    end

    assert_response :forbidden
  end

  test "deleting comments requires authorization" do
    user = create(:user)
    article = create(:article, slug: "some-slug")
    comment = create(:comment, user: user, article: article)

    assert_no_changes -> { article.comments.count } do
      delete(article_comment_url(article_slug: "some-slug", id: comment.id))
    end

    assert_response :unauthorized
  end

  private

  def authorization_headers_for(user)
    token = JWT.encode({id: user.id}, Rails.application.secrets.secret_key_base)
    {"Authorization" => "Bearer #{token}"}
  end
end
