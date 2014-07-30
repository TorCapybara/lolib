class ReportsController < ApplicationController
  respond_to :html

  def index
    authorize! :index, Report
    @reports = Report.accessible_by(current_ability).order(:handled).order('created_at DESC').paginate(:page => params[:page])

    add_to_crumbs(['Reported Posts', reports_path])
  end

  def create
    @report = Report.new(params.require(:report).permit(:message, :post_id))
    @report.reporter = current_user

    authorize! :create, @report

    @report.save

    redirect_to view_context.link_to_post_in_thread(@report.post) , :notice => 'Report was succesfully created.'
  end

  def show
    @report = Report.find(params[:id])
    authorize! :read, @report
    add_to_crumbs(@report)
  end

  def edit
    @report = Report.find(params[:id])
    authorize! :update, @report

  end

  def update
    @report = Report.find(params[:id])
    authorize! :update, @report

    @report.update_attributes(params.require(:report).permit(:message, :handled))

    redirect_to reports_path
  end
end
