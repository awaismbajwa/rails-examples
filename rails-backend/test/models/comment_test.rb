# frozen_string_literal: true

require "test_helper"

class CommentTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  test "is invalid if body is blank" do
    comment = build(:comment, body: "")

    assert_not comment.valid?
    assert_includes comment.errors.keys, :body
  end

  test "allows user to be blank" do
    article = create(:article)
    comment = build(:comment, article: article, user: nil)

    assert comment.valid?
  end

  test "is invalid if article is blank" do
    comment = build(:comment, article: nil)

    assert_not comment.valid?
    assert_includes comment.errors.keys, :article
  end
end
