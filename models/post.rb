class Post < Sequel::Model
  one_to_many :comments

  def self.api_collection
    self.eager(:comments)
  end

  def derived_method
    "derived_method_#{id}"
  end

  def self.permitted_update_params
    ['title']
  end
  
  def comments=(comments)
    comments.each do |comment|
      Comment.create(:post_id => self.id, :comment => comment["comment"])
    end
  end
end
