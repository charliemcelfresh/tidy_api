class Comment < Sequel::Model
  many_to_one :post

  def self.api_collection
    self
  end
end
