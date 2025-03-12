class Api::V1::UsersController < Api::V1::ApiController
	after_action :verify_authorized

	def index
		authorize User
		@users = policy_scope(User)
		render json: UserSerializer.new(@users).serializable_hash
	end

	def show
		@user = User.find(params[:id])
		authorize @user
		render json: UserSerializer.new(@user).serializable_hash.to_json
	end

	def update
		@user = User.find(params[:id])
		authorize @user
		if @user.update(user_params)
			render json: UserSerializer.new(@user).serializable_hash
		else
			render json: { errors: @user.errors }, status: :unprocessable_entity
		end
	end

	def destroy
		@user = User.find(params[:id])
		authorize @user
		@user.destroy
		render json: { message: 'Usuario eliminado correctamente.' }, status: :ok
	end

	private
	def user_params
		params.require(:user).permit(:email, :password, :password_confirmation)
	end
end