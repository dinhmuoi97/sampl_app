class Micropost < ApplicationRecord
  belongs_to :user
  scope :order_desc, ->{order created_at: :desc}
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum: Settings.micro_forty}

  private

  def picture_size
    return unless picture.size > Settings.size_picture.megabytes
    errors.add :picture, t("less_than")
  end
end
