class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :company, :email, :approved, :updated_status_at, :status, :budget, :role, :role_name
  def status
    if updated_status_at.nil?
      'Pending'
    else
      approved ? 'Approved' : 'Unapproved'
    end
  end

  def role
    object.roles.last.id
  end

  def role_name
    object.roles.last.name    
  end
end
