require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../helpers/resource_spec_helper')
describe GamesController do

  it_should_behave_like "a restfully routed resource"

  describe "actions" do
    before do
      @resource_class = Game
      @resource = Factory(:game)
      @other_resource= Factory(:game)
      @good_attributes = HashWithIndifferentAccess.new(Factory.attributes_for(:game))
      @bad_attributes = HashWithIndifferentAccess.new(Factory.attributes_for(:game, :name => ""))
      @resource_count_before = Game.count
    end


    class Hash
      def without_automatic_fields
        copy = self.dup
        [:id, :created_at, :updated_at].each { |key| copy.delete(key); copy.delete(key.to_s) }
        copy
      end
    end


    describe "#index" do
      before do
        it "should fetch and assign all resources for listing" do
          get :index
          assigns(@resource_class.to_s.underscore.pluralize.to_sym).should =~ [@resource, @other_resource]
        end
      end
    end

    describe "#show" do
      it "should fetch and assign the resource for display" do
        get :show, :id => @resource.id
        assigns(@resource_class.to_s.underscore.to_sym).should == @resource
      end
    end


    describe "#new" do
      it "should fetch and assign a new resource to fill in" do
        get :new
        assigns(@resource_class.to_s.underscore.to_sym).should be_a(@resource_class)
        assigns(@resource_class.to_s.underscore.to_sym).should be_new_record
      end
    end

    describe "#edit" do
      it "should fetch and assign the resource to edit" do
        get :edit, :id => @resource.id
        assigns(@resource_class.to_s.underscore.to_sym).should == @resource
      end
    end


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
end