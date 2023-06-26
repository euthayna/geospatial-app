class TicketsController < ApplicationController
  include TicketsHelper

  def index
    @tickets = Ticket.order(:created_at).page(params[:page]).per(15)
  end

  def show
    @ticket = Ticket.find(params[:id])
  end
end