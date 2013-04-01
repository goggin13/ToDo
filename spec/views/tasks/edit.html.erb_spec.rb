require 'spec_helper'

describe "tasks/edit" do
  before(:each) do
    @task = assign(:task, stub_model(Task,
      :description => "MyString",
      :list_id => 1,
      :completed => false
    ))
  end

  it "renders the edit task form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => tasks_path(@task), :method => "post" do
      assert_select "input#task_description", :name => "task[description]"
      assert_select "input#task_list_id", :name => "task[list_id]"
      assert_select "input#task_completed", :name => "task[completed]"
    end
  end
end
