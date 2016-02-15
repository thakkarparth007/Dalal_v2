class ApiController < ActionController::Base
	include ApiHelper
	before_filter :check_credentials!
	
	def index
		render :text => "Hello " + @cur_user.username + " :)"
	end
	
	def get_market_events
		skip = params[:skip] || 0
		limit = params[:limit] || 7
		company_name = params[:company]
		if(company_name != nil) then
			stock = Stock.where('stockname' => company_name).first
			@market_events_paginate = MarketEvent.order('created_at DESC').where('stock_id' => stock.id).limit(limit).offset(skip)
		else
			@market_events_paginate = MarketEvent.order('created_at DESC').limit(limit).offset(skip)		
		end
		
		@market_events_total = MarketEvent.count
		
		render :json => {
			market_events_total: @market_events_total,
			market_events_list: @market_events_paginate
		}
	end
	
	def get_stocks
		Stock.connection.clear_query_cache
		@stocks_list = Stock.all
		@price_of_tot_stock = Stock.get_total_stock_price(@cur_user.id)
		User.calculate_total(@cur_user.id)
		@user_current_cash = @cur_user.cash.round(2)
		
		render :json => {
			stocks_list: @stocks_list,
			price_of_tot_stock: @price_of_tot_stock,
			user_current_cash: @user_current_cash,
			user_total_calculator: @cur_user.total
		}
	end
	
	def get_notifications
		skip = params[:skip] || 0
		limit = params[:limit] || 10
		@notifications_list = Notification.select("notification,updated_at,id").where('user_id' => @cur_user.id).order('created_at DESC').limit(limit).offset(skip)
		
		render :json => {
			notifications_list: @notifications_list
		}
	end
	
	def get_leaderboard
		page = params[:page] || 1
		if(page < 1) then 
			page = 1 
		end
		
		limit = params[:limit] || 30
		@user_leader = User.paginate(:page => page,:per_page => limit).order('total DESC')
		
		render :json => {
			leaderboard: @user_leader
		}
	end
	
end
