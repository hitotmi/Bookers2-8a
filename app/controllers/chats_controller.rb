class ChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :reject_non_related, only: [:show]

  def show
    @user = User.find(params[:id])
    rooms = current_user.user_rooms.pluck(:room_id)
    user_room = UserRoom.find_by(user_id: @user.id, room_id: rooms)
    if user_room.present?
      @room = user_room.room
    else
      @room = Room.create
      UserRoom.create(user_id: current_user.id, room_id: @room.id)
      UserRoom.create(user_id: @user.id, room_id: @room.id)
    end
    @chats = @room.chats
    @chat = Chat.new(room_id: @room.id)
  end

  def create
    @chat = current_user.chats.new(chat_params)
    @room = @chat.room
    @chats = @room.chats
    if @chat.save
      redirect_to request.referer
    else
      render 'show'
    end
  end

  private
  def reject_non_related
    user = User.find(params[:id])
    unless current_user.following?(user) && user.following?(current_user)
      redirect_to books_path
    end
  end

  def chat_params
    params.require(:chat).permit(:message, :room_id)
  end


end
