require 'rails_helper'

RSpec.describe UserSerializer do
  let(:user) { User.create(
    id: 1, 
    name: 'Test User', 
    email: 'test@example.com', 
    password_digest: 'hashed_password', 
    confirmed: true,
    confirmed_at: Time.now,
    sign_in_count: 2,
    current_sign_in_at: Time.now,
    last_sign_in_at: 1.day.ago,
    banned: false
  ) }
  let(:serialization) { JSON.parse(UserSerializer.new(user).serializable_hash.to_json) }

  it 'follows the JSON:API format' do
    expect(serialization).to have_key('data')
    expect(serialization['data']).to have_key('id')
    expect(serialization['data']).to have_key('type')
    expect(serialization['data']).to have_key('attributes')
    expect(serialization['data']['type']).to eq('user')
  end

  it 'includes the expected attributes' do
    attributes = serialization['data']['attributes']
    
    expect(attributes).to include(
      'id', 'email', 'created_at', 'updated_at', 'sign_in_count',
      'current_sign_in_at', 'last_sign_in_at', 'confirmed',
      'confirmed_at', 'banned', 'banned_at', 'ban_reason', 'roles'
    )
  end

  it 'does not include sensitive attributes' do
    attributes = serialization['data']['attributes']
    
    expect(attributes.keys).not_to include('password', 'password_digest')
  end

  it 'formats roles as an array' do
    expect(serialization['data']['attributes']['roles']).to be_an(Array)
  end

  it 'matches the user attributes' do
    attributes = serialization['data']['attributes']
    
    expect(attributes['id']).to eq(user.id)
    expect(attributes['email']).to eq(user.email)
    expect(attributes['confirmed']).to eq(true)
    expect(attributes['banned']).to eq(false)
    expect(attributes['ban_reason']).to be_nil
  end
end
