shared_examples_for "a restfully routed resource" do

  describe "resource routes" do

    it "should route to restful index" do
      should route(:get, "/#{@resource_name}").to(:controller => @resource_symbol, :action => :index)
    end

    it "should route to restful show" do
      should route(:get, "/#{@resource_name}/1").to(:controller => @resource_symbol, :action => :show, :id => 1)
    end

    it "should route to restful new" do
      should route(:get, "/#{@resource_name}/new").to(:controller => @resource_symbol, :action => :new)
    end

    it "should route to restful edit" do
      should route(:get, "/#{@resource_name}/1/edit").to(:controller => @resource_symbol, :action => :edit, :id => 1)
    end

    it "should route to restful create" do
      should route(:post, "/#{@resource_name}").to(:controller => @resource_symbol, :action => :create)
    end

    it "should route to restful update" do
      should route(:put, "/#{@resource_name}/1").to(:controller => @resource_symbol, :action => :update, :id => 1)
    end

    it "should route to restful destroy" do
      should route(:delete, "/#{@resource_name}/1").to(:controller => @resource_symbol, :action => :destroy, :id=> 1)
    end
  end
end

