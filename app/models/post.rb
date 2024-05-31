# app/models/post.rb
class Post < ApplicationRecord
    has_one_attached :image
    has_one_attached :file
  
    validate :image_validation
    validate :file_type_validation
  
    private
  
    def image_validation
      if image.attached?
        unless image.content_type.in?(%w(image/png image/jpg image/jpeg image/webp))
          errors.add(:image, 'must be a PNG, JPG, JPEG, or WEBP file')
        end
        unless image.byte_size <= 5.megabytes
          errors.add(:image, 'size should be less than 5MB')
        end
      else
        errors.add(:image, 'must be attached')
      end
    end
  
    def file_type_validation
        if file.attached?
          unless file.blob.filename.to_s.ends_with?('.py')
            errors.add(:file, 'must be a Python file')
          end
        else
          errors.add(:file, 'must be attached')
        end
    end
  end
  