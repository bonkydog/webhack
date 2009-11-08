require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
describe UserSessionsController do


  describe "routes" do
    before do
      @resource_name = "user_session"
      @resource_symbol = :user_sessions
    end


    describe "resource routes" do

      it "should route to restful show" do
        should route(:get, "/user_session").to(:controller => @resource_symbol, :action => :show)
      end

      it "should route to restful edit" do
        should route(:get, "/user_session/edit").to(:controller => @resource_symbol, :action => :edit)
      end

      it "should route to restful create" do
        should route(:post, "/user_session").to(:controller => @resource_symbol, :action => :create)
      end

      it "should route to restful update" do
        should route(:put, "/user_session").to(:controller => @resource_symbol, :action => :update)
      end

      it "should route to restful destroy" do
        should route(:delete, "/user_session").to(:controller => @resource_symbol, :action => :destroy)
      end
    end
  end

  describe "actions" do

    before do
      @user = Factory(:user)
    end


    describe "#new" do
      it "should create and assign a new session" do
        get :new
        assigns(:user_session).should be_a(UserSession)
        assigns(:user_session).should be_new_record
      end
    end

    describe "#create" do

      context "with successful login" do
        before do
          post :create, :user_session => {:login => @user.login, :password => "cockatrice"}
        end

        it "should log the user in " do
          session = UserSession.find
          session.should_not be_nil
          session.user.should == @user
        end

        it "should redirect to the new game page" do
          response.should redirect_to(new_game_url)
        end

      end

      context "failed login" do
        before do
          post :create, :user_session => {:login => @user.login, :password => "wrong!"}
        end

        it "should not log the user in" do
          UserSession.find.should be_nil
        end

        it "should render new (the login page) again" do
          response.should render_template(:new)
        end

      end
    end

    describe "#destroy" do
      before do
        user_session = UserSession.new(:login => @user.login, :password => "cockatrice")
        user_session.save!
        UserSession.find.should_not be_nil

        delete :destroy, :user_session => user_session
      end

      it "should log the user out" do
        UserSession.find.should be_nil
      end

      it "should redirect home" do
        response.should redirect_to("/")
      end

    end

  end


end