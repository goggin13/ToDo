require 'spec_helper'

describe "Lecture 10" do
  
  before do
    @user = User.create! email: 'matt@example.com',
                         password: 'password',
                         password_confirmation: 'password'
  end

  def login_user(user)
    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: user.password
    click_button "Sign in"
    page.should have_content "Signed in successfully."
  end

  describe "initial layout" do
    
    describe "authenticated" do
      
      before do
        login_user @user
      end

      it "should have a link for the lists index page" do
        page.should have_link "Home"
      end

      it "should have a link to My Account" do
        page.should have_link "My Account"
      end

      it "should have a link to Logout" do
        page.should have_link "Logout"
      end
    end

    describe "anonymous" do

      before do
        visit root_path
      end

      it "should have a link to Sign up" do
        page.should have_link "Sign up"
      end

      it "should have a link to Sign in" do
        page.should have_link "Sign in"
      end
    end
  end

  describe "Home page" do
    
    it "should redirect anonymous users to the sign_in page" do
      visit root_path
      page.should have_content "Sign in"
    end
    
    it "should show authenticated users the lists index page" do
      login_user @user
      visit root_path
      page.should have_content "Listing lists"
    end
  end

  describe "creating lists" do

    it "should assign a new list to the current user" do
      login_user @user
      visit new_list_path
      fill_in "Title", with: "Test title"
      expect {
        click_button "Create List"
      }.to change(@user.lists, :count).by 1
    end
  end

  describe "list access control" do
    
    before do
      login_user @user
    end

    it "should allow you to edit your own list" do
      list = @user.lists.create! title: "My List"
      visit edit_list_path(list)
      page.should have_content "Editing list" 
    end

    it "should not allow you to edit someone else's list" do
      friend = User.create! email: 'friend@example.com',
                            password: 'password',
                            password_confirmation: 'password'
      list = friend.lists.create! title: "My List"
      visit edit_list_path(list)
      page.should have_content "You are not authorized to edit that list"
    end    
  end

  describe "managing tasks" do
    
    before do 
      login_user @user
      5.times { |i| @user.lists.create! title: "List #{i}" }
    end

    describe "creating a new task" do
      
      before do
        visit new_task_path
      end

      it "should offer a select dropdown for lists" do
        5.times do |i|
           page.should have_xpath "//select/option[text() = 'List #{i}']"
        end
      end

      it "should assign it to the list from the drop down" do
        list = List.first
        page.select list.title, from: "List"
        fill_in "Description", with: "a test description"
        expect {
          click_button "Create Task"
        }.to change(list.tasks, :count).by 1
      end

      it "should redirect to the lists page" do
        list = List.first
        page.select list.title, from: "List"
        fill_in "Description", with: "a test description"
        click_button "Create Task"
        page.should have_content list.title
      end
    end

    describe "editing a task" do
        
      before do
        @list = @user.lists.create! title: "My List"
        @task = @list.tasks.create! description: "Sample description"
        visit edit_task_path(@task)
      end

      it "should redirect to the list page" do
        click_button "Update Task"
        page.should have_content @list.title
      end
    end
  end

  describe "a list page" do
    
    before do
      @list = @user.lists.create! title: "My List"
      5.times { |i| @list.tasks.create! description: "a sample description - #{i}" }
    end

    describe "when you own the list" do
      
      before do
        login_user @user
        visit list_path(@list)
      end

      it "should have a link to edit the list" do
        page.should have_link "Edit"
      end 

      it "should have a link to destroy the list" do
        page.should have_link "Delete"
      end
    end

    describe "when you do not own the list" do
      
      before do
        user = User.create! email: 'theDude@example.com',
                            password: 'password',
                            password_confirmation: 'password'
        login_user user
        visit list_path(@list)
      end

      it "should not have a link to edit the list" do
        page.should_not have_link "Edit List"
      end 

      it "should not have a link to destroy the list" do
        page.should_not have_link "Destroy"
      end 

      it "should display all the tasks" do
        5.times { |i| page.should have_content "a sample description - #{i}" }
      end
    end
  end

  describe "list pagination" do
    
    before do
      35.times { |i| @user.lists.create! title: "My List - #{i} -" }
      login_user @user
    end

    it "should only display 30 lists" do
      30.times { |i| page.should have_content "My List - #{i} -" }
      (30..34).each { |i| page.should_not have_content "My List - #{i} -" }
    end

    it "should display the remainder on the second page" do
      visit lists_path(page: 2)
      30.times { |i| page.should_not have_content "My List - #{i} -" }
      (30..34).each { |i| page.should have_content "My List - #{i} -" }
    end

    it "should display a link to the next page of lists" do
      page.should have_link "2"
    end
  end
end
