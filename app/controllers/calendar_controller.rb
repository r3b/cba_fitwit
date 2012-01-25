class CalendarController < ApplicationController
  
  def events
    @events = Event.where(location_id: params[:id]).all.to_a
    @event_days = @events.group_by {|t| t.starts_at.beginning_of_day }
    # we want to group these by day and get them in the format:
    #      events = [
    #    Title: "Five K for charity " + this.id
    #    Date: new Date("01/13/2012")
    #  ,
    #    Title: "Dinner"
    #    Date: new Date("01/25/2012")
    #  ,
    #    Title: "Meeting with manager"
    #    Date: new Date("01/01/2012")
    #  ]

    out = @event_days.map{|day, events| {Date: day.strftime('%m/%d/%Y'), Title: events.map(&:title).to_sentence}}

    render json: out.to_json
  end
  
end
