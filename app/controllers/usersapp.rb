UserManagementWebapp::App.controllers :usersapp do

	before :edit, :update  do
		# redirect('/login') unless signed_in?
		# @user = User.find_by_id(params[:id])
		# redirect('/login') unless current_user?(@user)
	end

	get :redirecting, :map => "" do
		redirect  url('http://localhost:3000/v1.0/oauth/authorize?client_id=8wwncodsjcajmmw1yutgnjc5kfmad7j&response_type=token&redirect_uri=localhost:3001',:Authorization => "test")
	end

	get :new, :map => "/register" do
		@user = User.new
		render 'new'
	end

	post :create , :map => '/users/create' do
		VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
		params=request.params['user']
		if !(params['email']  =~ VALID_EMAIL_REGEX )
			{"error" => "email is not in email regex form"}
		elsif (params['password'].length < 5)
			{"error" => "password too short"}
		elsif (params['password'] != params['password_confirmation'])
			{"error" => "password do not match"}
		else
			response=UserHttpReqeust.post_json("/users/",nil,nil,params)
			if response.code == 204
				flash[:notice] = "You have been registered. Please confirm with the mail we've send you recently."
				redirect('/')
			else
				response.body
			end
		end
	end

	get :readuser , :map => '/users/:id/read' do
		auth_token=current_token()
		response=UserHttpReqeust.get("/users/",nil,{"Authorization"=>auth_token})
		response.body
	end
	get :edit, :map => '/users/:id/edit' do
		render 'edit'
	end

	put :update, :map => '/users' do
		auth_token=current_token()
		params=request.params['string']
		response=UserHttpReqeust.put_json("/users/",nil,{"Authorization"=>auth_token},params)
		if response.code == 201
			flash[:notice] = "Profile Updated"
		end
		redirect('/')
	end
end
