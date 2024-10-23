# frozen_string_literal: true

# A helper module for generating and validating text captcha questions
# and answers.
#
# Usage:
#
#     require "text_captcha"
#
#     # Get a question
#     item = TextCaptcha.get
#
#     item[:question] # => "1 + 1 = ?"
#     item[:key] # => A key that needs to be passed back in to `valid_answer?` to identify the question
#
#     # Validating an answer
#     TextCaptcha.valid_answer?(item[:key], "2") # => true
#     TextCaptcha.valid_answer?(item[:key], "wrong") # => false
#
# The key can be passed to the client to identify the question on
# validation without revealing the answer.
#
# In tests the set of questions can be overriden to ensure the same
# question in asked each time:
#
#     class CommentsControllerTest < ActionDispatch::IntegrationTest
#       setup do
#         TextCaptcha.questions = [
#           {question: "question", answer: "correct answer"}
#         ]
#       end
#
#       teardown do
#         TextCaptcha.questions = TextCaptcha::DEFAULT_QUESTIONS
#       end
#
#       test "" do
#          ...
module TextCaptcha
  DEFAULT_QUESTIONS = [
    {
      question: "1 + 1 = ?",
      answer: "2"
    },
    {
      question: "Which of sock, library, cake or red is a colour?",
      answer: "red"
    }
  ]

  mattr_accessor(:questions, default: DEFAULT_QUESTIONS)

  # Returns a hash including a random question and a key (which needs
  # to passed to `#valid_answer?` to identify the question).
  def self.get
    index = Random.rand(questions.size)
    item = questions[index]

    {
      key: index,
      question: item[:question]
    }
  end

  # Check if the given answer is correct. The key parameter needs to
  # be set to the corresponding `key` returned in the hash generated
  # by `#get`.
  def self.valid_answer?(key, answer)
    key = key.to_i
    !!questions[key] && answer == questions[key][:answer]
  end
end
