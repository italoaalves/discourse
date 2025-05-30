# frozen_string_literal: true

describe "Viewing categories page", type: :system do
  fab!(:user)
  fab!(:category)
  fab!(:topic) { Fabricate(:topic, category: category) }
  fab!(:post) { Fabricate(:post, topic: topic) }
  let(:category_list) { PageObjects::Components::CategoryList.new }
  let(:topic_view) { PageObjects::Components::TopicView.new }

  context "when viewing top topics" do
    it "displays and updates new counter" do
      sign_in(user)

      visit("/categories")

      category_list.click_new_posts_badge(count: 1)
      category_list.click_topic(topic)

      expect(topic_view).to have_read_post(post)

      category_list.click_logo
      category_list.click_category_navigation

      expect(category_list).to have_category(category)
      expect(category_list).to have_no_new_posts_badge
    end
  end

  context "when viewing the category's topic list" do
    let(:topic_list) { PageObjects::Components::TopicList.new }

    context "when parent category has default_list_filter=none" do
      fab!(:parent_category) { Fabricate(:category_with_definition, default_list_filter: "none") }
      fab!(:subcategoryA) { Fabricate(:category_with_definition, parent_category: parent_category) }
      fab!(:topic) { Fabricate(:topic, category: subcategoryA) }
      fab!(:post) { create_post(topic: topic) }

      it "lists the topic on the subcategory" do
        visit "/c/#{parent_category.slug}/#{subcategoryA.slug}"
        expect(topic_list).to have_topic(topic)
      end

      it "does not list the topic on the parent category" do
        visit "/c/#{parent_category.slug}"
        expect(topic_list).to have_no_topic(topic)
      end
    end
  end
end
