# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :article

  validates :body, presence: true, allow_blank: false
end
