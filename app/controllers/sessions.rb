UserManagementWebapp::App.controllers :sessions do
  get :new, :map => "/login" do
    render 'new', :locals => { :error => false ,:notconfirmation => false }
  end

  get :create , :map => 'sessions/create' do
	  response=UserHttpReqeust.get("/users/",{"oauth_token"=>params[:Authorization]},{"Authorization"=>params[:Authorization]})
	  flash[:notice] = "You have successfully logged in!"
      id=response.json_body['_id']
	  @name=response.json_body['name']
	  setauthheader(params[:Authorization])
	  sign_in(id)
	  flash[:notice] = "Welcome #{@name}"
	  redirect '/'
	  flash[:notice] = "Welcome #{@name}"
  end

  get :destroy, :map => '/logout' do
    sign_out
    flash[:notice] = "You have successfully logged out."
    redirect '/'
  end
end

