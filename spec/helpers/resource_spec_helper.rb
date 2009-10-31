
class Hash
  def without_automatic_fields
    copy = self.dup
    [:id, :created_at, :updated_at].each { |key| copy.delete(key); copy.delete(key.to_s) }
    copy
  end
end


shared_examples_for "a restfully indexed resource" do
  describe "#index" do
    it "should fetch and assign all resources for listing" do
      get :index
      assigns(@resource_class.to_s.underscore.pluralize.to_sym).should =~ [@resource, @other_resource]
    end
  end
end

shared_examples_for "a restfully shown resource" do
  describe "#show" do
    it "should fetch and assign the resource for display" do
      get :show, :id => @resource.id
      assigns(@resource_class.to_s.underscore.to_sym).should == @resource
    end
  end

end

shared_examples_for "a restfully newed resource" do
  describe "#new" do
    it "should fetch and assign a new resource to fill in" do
      get :new
      assigns(@resource_class.to_s.underscore.to_sym).should be_a(@resource_class)
      assigns(@resource_class.to_s.underscore.to_sym).should be_new_record
    end
  end
end

shared_examples_for "a restfully edited resource" do
  describe "#edit" do
    it "should fetch and assign the resource to edit" do
      get :edit, :id => @resource.id
      assigns(@resource_class.to_s.underscore.to_sym).should == @resource
    end
  end

end

shared_examples_for "a restfully created resource" do
  describe "#create" do
    context "with valid resource" do
      before do
        post :create, @resource_class.to_s.underscore.to_sym => @good_attributes
      end
      it "should create a resource" do
        @resource_class.count.should == @resource_count_before + 1
      end

      it "should redirect to the resources index" do
        response.should redirect_to(:action => "index")
      end

      it "should flash a notice" do
        flash[:notice].should_not be_nil
      end
    end

    context "with invalid resource" do
      before do
        post :create, @resource_class.to_s.underscore.to_sym => @bad_attributes
      end

      it "should not create a resource" do
        @resource_class.count.should == @resource_count_before
      end

      it "should assign resource for correction" do
        assigns(@resource_class.to_s.underscore.to_sym).should be_a(@resource_class)
        assigns(@resource_class.to_s.underscore.to_sym).should be_new_record
      end

      it "should render edit" do
        response.should render_template(:new)
      end

    end
  end

end


shared_examples_for "a restfully updated resource" do
  describe "#update" do
    context "with valid resource" do
      before do
        put :update, :id => @resource.id, @resource_class.to_s.underscore.to_sym => @good_attributes
      end

      it "should not update the record" do
        @resource.reload.attributes.without_automatic_fields.should == @good_attributes
      end


      it "should redirect to the resources index" do
        response.should redirect_to(:action => "index")
      end

      it "should flash a notice" do
        flash[:notice].should_not be_nil
      end
    end

    context "with invalid resource" do
      before do
        put :update, :id => @resource.id, @resource_class.to_s.underscore.to_sym => @bad_attributes
      end

      it "should not update the record" do
        @resource.reload.attributes.without_automatic_fields.should_not == @bad_attributes
      end

      it "should assign resource for correction" do
        assigns(@resource_class.to_s.underscore.to_sym).should == @resource
      end

      it "should render edit" do
        response.should render_template(:edit)
      end
    end
  end
end

shared_examples_for "a restfully destroyed resource" do
  describe "#destroy" do
    before do
      delete :destroy, :id => @resource.id
    end

    it "should delete the resource" do
      @resource_class.find_by_id(@resource.id).should be_nil
    end

    it "should redirect to to resources index" do
      response.should redirect_to(:action => "index")
    end
  end
end


shared_examples_for "a restfully routed resource" do

  describe "resource routes" do

    before do
      @name = described_class.name.sub(/Controller$/, '').underscore
      @resource_symbol = @name.to_sym
    end

    it "should route to restful index" do
      should route(:get, "/#{@name}").to(:controller => @resource_symbol, :action => :index)
    end

    it "should route to restful show" do
      should route(:get, "/#{@name}/1").to(:controller => @resource_symbol, :action => :show, :id => 1)
    end

    it "should route to restful edit" do
      should route(:get, "/#{@name}/1/edit").to(:controller => @resource_symbol, :action => :edit, :id => 1)
    end

    it "should route to restful create" do
      should route(:post, "/#{@name}").to(:controller => @resource_symbol, :action => :create)
    end

    it "should route to restful update" do
      should route(:put, "/#{@name}/1").to(:controller => @resource_symbol, :action => :update, :id => 1)
    end

    it "should route to restful destroy" do
      should route(:delete, "/#{@name}/1").to(:controller => @resource_symbol, :action => :destroy, :id=> 1)
    end
  end
end

shared_examples_for "a restfully controlled resource" do
  it_should_behave_like "a restfully indexed resource"
  it_should_behave_like "a restfully shown resource"
  it_should_behave_like "a restfully newed resource"
  it_should_behave_like "a restfully edited resource"
  it_should_behave_like "a restfully created resource"
  it_should_behave_like "a restfully updated resource"
  it_should_behave_like "a restfully destroyed resource"
end