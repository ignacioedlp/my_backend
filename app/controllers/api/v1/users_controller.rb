class Api::V1::UsersController < Api::V1::ApiController
	after_action :verify_authorized
	# We don't need verify_policy_scoped since we're using authorize

	def index
		authorize User
		@users = policy_scope(User)
		render json: @users
	end

	def show
		@user = User.find(params[:id])
		authorize @user
		render json: @user
	end

	def update
		@user = User.find(params[:id])
		authorize @user
		if @user.update(user_params)
			render json: @user
		else
			render json: { errors: @user.errors }, status: :unprocessable_entity
		end
	end

	def destroy
		@user = User.find(params[:id])
		authorize @user
		@user.destroy
		head :no_content
	end

	private
	def user_params
		params.require(:user).permit(:email, :password, :password_confirmation)
	end
end