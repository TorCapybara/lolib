class StatisticsController < ApplicationController
  respond_to :html

  def index
  end

  def show
    @type = params[:id]
    @total = Statistics.where('counter_type = ? and scope = "global"', @type).first
    @statistics = Statistics.where('counter_type = ? and scope <> "global"', @type)
    @maximum = @statistics.maximum(:counter)
  end
end
