class Role < ApplicationRecord
  audited
  has_and_belongs_to_many :users, join_table: :users_roles

  belongs_to :resource,
             polymorphic: true,
             optional: true


  validates :resource_type,
            inclusion: { in: Rolify.resource_types },
            allow_nil: true

  scopify

  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "id", "id_value", "name", "resource_id", "resource_type", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "resource", "users" ]
  end
end
