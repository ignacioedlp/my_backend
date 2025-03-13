class Api::V1::UsersController < Api::V1::ApiController
  after_action :verify_authorized
  before_action :set_user, only: %i[show update destroy ban unban]

  # GET /api/v1/users
  def index
    authorize User
    @users = policy_scope(User)
    render json: UserSerializer.new(@users).serializable_hash
  end

  # GET /api/v1/users/:id
  def show
    authorize @user
    render json: UserSerializer.new(@user).serializable_hash.to_json
  end

  # PUT /api/v1/users/:id
  def update
    authorize @user
    if @user.update(user_params)
    render json: UserSerializer.new(@user).serializable_hash
    else
    render json: { errors: @user.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/users/:id
  def destroy
    authorize @user
    @user.destroy
    render json: { message: "User successfully deleted." }, status: :ok
  end

  # POST /api/v1/users/:id/ban
  def ban
    authorize @user, :ban?

    reason = params[:reason]
    @user.ban!(reason)

    render json: {
    message: "User successfully suspended.",
    user: UserSerializer.new(@user).serializable_hash
    }, status: :ok
  end

  # POST /api/v1/users/:id/unban
  def unban
    authorize @user, :unban?

    @user.unban!

    render json: {
    message: "User suspension has been lifted.",
    user: UserSerializer.new(@user).serializable_hash
    }, status: :ok
  end

  private

  # Strong parameters for user
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end


  # Set user
  def set_user
    @user = User.find_by(id: params[:id])

    unless @user
    render json: { error: "User not found." }, status: :not_found
    end
  end
end
