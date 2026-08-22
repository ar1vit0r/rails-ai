class Conversation < ApplicationRecord
  belongs_to :user
  has_many :messages, dependent: :destroy

  validates :title, presence: true

  def history
    messages.order(:created_at).map { |m| { role: m.role, content: m.content } }
  end
end
