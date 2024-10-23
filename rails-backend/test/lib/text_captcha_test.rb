# frozen_string_literal: true

require 'test_helper'
require 'text_captcha'

class TextCaptchaTest < ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  setup do
    TextCaptcha.questions = [
      {question: "question", answer: "correct answer"}
    ]
  end

  teardown do
    TextCaptcha.questions = TextCaptcha::DEFAULT_QUESTIONS
  end

  test "#get returns question and key" do
    item = TextCaptcha.get

    assert_equal "question", item[:question]
    assert item[:key].present?
  end

  test "#valid_answer? returns true for correct answer and key" do
    item = TextCaptcha.get

    result = TextCaptcha.valid_answer?(item[:key], "correct answer")

    assert_equal true, result
  end

  test "#valid_answer? returns false for wrong answer" do
    item = TextCaptcha.get

    result = TextCaptcha.valid_answer?(item[:key], "wrong")

    assert_equal false, result
  end

  test "#valid_answer? returns false for wrong key" do
    result = TextCaptcha.valid_answer?(42, "correct answer")

    assert_equal false, result
  end
end
