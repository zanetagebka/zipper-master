class Attachment < ApplicationRecord
  has_one_attached :file
  belongs_to :user

  validate :check_file_presence

  private

  def check_file_presence
    errors.add(:file, "must be attached") unless file.attached?
  end
end
