require 'rails_helper'

describe Api::V1::UsersController, type: :controller do
  before(:each) { request.headers['Accept'] = 'application/vnd.marketplace.v1' }

  describe 'GET #show' do
    before(:each) do
      @user = FactoryGirl.create :user
      get :show, id: @user.id, format: :json
    end

    it 'returns the information about a reporter on a hash' do
      user_response = JSON.parse(response.body, symbolize_names: true)
      expect(user_response[:email]).to eql @user.email
    end

    it { should respond_with 200}
  end

  describe 'POST #create' do
    context 'when is successfully created' do
      it 'renders the json representation for the user record just created' do
        @user_attributes = FactoryGirl.attributes_for :user
        post :create, { user: @user_attributes }, format: :json

        user_response = JSON.parse(response.body, symbolize_names: true)
        
        expect(user_response[:email]).to eql @user_attributes[:email]
        expect(response).to have_http_status(:created)
      end
    end

    context 'when is not created' do
      before(:each) do
        #notice I'm not including the email
        @invalid_user_attributes = { password: "12345678",
                                     password_confirmation: "12345678" }                                    
      end

      it 'renders an errors json' do
        post :create, { user: @invalid_user_attributes }, format: :json 

        user_response = JSON.parse(response.body, symbolize_names: true)
        
        expect(user_response).to have_key(:errors)
        expect(response).to have_http_status(422)
      end

      it 'renders the json errors on why the user could not be created' do
        post :create, { user: @invalid_user_attributes }, format: :json 

        user_response = JSON.parse(response.body, symbolize_names: true)
        
        expect(user_response[:errors][:email]).to include "can't be blank"
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'PUT/PATCH #update' do
    context 'when is successfully updated' do
      it "renders the json representation for the updated user" do
        user = FactoryGirl.create :user
        patch :update, { id: user.id, user: { email: 'newmail@example.com' } }, format: :json

        user_response = JSON.parse(response.body, symbolize_names: true)
        
        expect(user_response[:email]).to eq 'newmail@example.com'
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when is not updated' do
      it 'renders an errors JSON' do
        @user = FactoryGirl.create :user
        patch :update, { id: @user.id,
                         user: { email: "bademail.com" } }, format: :json

        user_response = JSON.parse(response.body, symbolize_names: true)
        
        expect(user_response).to have_key(:errors)
        expect(response).to have_http_status(422)
      end

      it "renders the json errors on when the user could not be update" do
        @user = FactoryGirl.create :user
        patch :update, { id: @user.id,
                         user: { email: "bademail.com" } }, format: :json

        user_response = JSON.parse(response.body, symbolize_names: true)
        
        expect(user_response[:errors][:email]).to include 'is invalid'
        expect(response).to have_http_status(422)
      end
    end
  end

  describe 'DELETE #destory' do
    it 'deletes user successfully' do
      user = FactoryGirl.create :user
      delete :destroy, { id: user.id }, format: :json

      expect(response).to have_http_status(204)
    end
  end
end
