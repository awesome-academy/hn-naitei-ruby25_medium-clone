class Comment < ApplicationRecord
  PERMIT_PARAMS = %i(content article_id parent_id).freeze

  belongs_to :user
  belongs_to :article
  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: "parent_id",
            dependent: :destroy

  validates :content, presence: true, length: {maximum: 500}

  scope :first_level, ->{where(parent_id: nil)}

  def limit_depth_to_two_levels
    return unless parent.present? && parent.parent.present?

    errors.add(:base, "Comments can only be nested one level deep.")
  end
end
