class PrivateMessagesController < ApplicationController
  respond_to :html
  before_action :set_private_message, only: [:show, :update, :destroy]

  def index
    authorize! :index, PrivateMessage
    @private_messages = current_user.inbox_messages.order('created_at desc').paginate(:page => params[:page])

    add_to_crumbs ['PM Inbox', outbox_private_messages_path]
  end

  def outbox
    authorize! :index, PrivateMessage
    @private_messages = current_user.outbox_messages.order('created_at desc').paginate(:page => params[:page])

    add_to_crumbs ['PM Outbox', outbox_private_messages_path]
  end

  def show
    add_to_crumbs @private_message

    authorize! :read, @private_message

    @private_message.mark_read(current_user)
  end

  def send_to
    common_new

    @private_message.receiver = User.find(params[:id]) if params[:id]

    render :new
  end

  def reply
    common_new

    old_message = PrivateMessage.find(params[:id]) if params[:id]

    @private_message.subject = 'Re: ' + old_message.subject
    @private_message.receiver = old_message.sender
    @private_message.reply_id = old_message.id

    render :new
  end

  def new
    common_new
  end

  def create
    @private_message = PrivateMessage.new(private_message_params)
    @private_message.sender = current_user
    authorize! :create, @private_message

    if @private_message.parent and !@private_message.parent.can_see?(current_user)
      flash[:error] = 'Illegal Reply ID'
      @private_message.parent = nil
    end

    if @private_message.save
      redirect_to @private_message, notice: 'Message was successfully sent.'
    else
      render :new
    end
  end

  def destroy
    @private_message.destroy
    redirect_to private_messages_url
    head :no_content
  end

private
  def set_private_message
    @private_message = PrivateMessage.find(params[:id])
  end

  def private_message_params
    params.require(:private_message).permit(:receiver_id, :subject, :text, :reply_id)
  end

  def common_new
    authorize! :read, PrivateMessage
    @private_message = PrivateMessage.new
    add_to_crumbs @private_message
  end
end
