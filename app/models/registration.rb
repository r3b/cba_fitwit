class Registration

  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveModel::Validations

  belongs_to :user
  belongs_to :time_slot  # , :null => false
  belongs_to :order
  has_many :friends
  belongs_to :fitness_camp

  validates :user_id, presence: true, uniqueness: {scope: :fitness_camp_id}, of_fitness_camp_location: true

  # does this do anything? is this deprecated?
  
#  def self.produce_registration(cart_item)
#    rsg = self.new
#    rsg.time_slot_id = cart_item.fitnesscamp.id
#    rsg.order_id = cart_item.order
#    rsg
#  end

end
