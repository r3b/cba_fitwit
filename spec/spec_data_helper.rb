# == SpecDataHelper
#
# Configured in 'spec_helper.rb' - config.include SpecDataHelper
# Functions we use in all specs to create test-data
#
module SpecDataHelper

  # Drop all documents of collections we'll test
  def cleanup_database
    begin
      FitnessCamp.unscoped.delete_all
      TimeSlot.unscoped.delete_all
      Workout.unscoped.delete_all
      Posting.unscoped.delete_all
      Blog.unscoped.delete_all
      User.unscoped.delete_all
      Location.unscoped.delete_all
      PageTemplate.delete_all
      Order.unscoped.delete_all
      Registration.unscoped.delete_all
      Page.delete_all
      MedicalCondition.delete_all
      puts "cleaned up database"
    rescue => e
      puts "*** ERROR CLEANING UP DATABASE -- #{e.inspect}"
    end
  end

  # Create the default user set.
  # Admin is created first because the first user will have admin-role instantly.
  # Then create users with other roles.
  # To use the default userset
  #     log_in_as "_role_@iboard.cc", "thisisnotsecret"
  # Where '_role_' can be one of:
  # * admin@iboard.cc
  # * user@iboard.cc
  # * author@iboard.cc
  # * moderator@iboard.cc
  # * maintainer@iboard.cc
  # * staff@iboard.cc
  def create_default_userset
    puts "creating default userset"
    User.unscoped.delete_all
    [
      #ROLES = [:guest, :confirmed_user, :author, :moderator, :maintainer, :admin]
      #see user.rb model
      #
      #  ATTENTION cba makes the first user an admin!
      #  -> The first user of the following hash must be the admin!
      {
        :email => 'admin@iboard.cc',
        :name  => 'admin',
        :first_name => 'Drew',
        :last_name => 'Adminer',
        :roles_mask => 5,
        :password => 'thisisnotsecret', :password_confirmation => 'thisisnotsecret'
      },
      # Define NON-ADMINS BELOW
      {
        :email => 'user@iboard.cc',
        :name  => 'testmax',
        :first_name => 'Drew',
        :last_name => 'Bradden',
        :roles_mask => 1,
        :password => 'thisisnotsecret', :password_confirmation => 'thisisnotsecret'
      },
      {
        :email => 'veteran@fitwit.com',
        :name  => 'veteran',
        :first_name => 'Michael',
        :last_name => 'Veteraner',
        :roles_mask => 1,
        :password => 'thisisnotsecret', :password_confirmation => 'thisisnotsecret',
        :veteran_status => :veteran
      },
      {
        :email => 'supervet@fitwit.com',
        :name  => 'supervet',
        :first_name => 'Supervetten',
        :last_name => 'Askancer',
        :roles_mask => 1,
        :password => 'thisisnotsecret', :password_confirmation => 'thisisnotsecret',
        :veteran_status => :supervet
      },
      {
        :email => 'newbie@fitwit.com',
        :name  => 'newbie',
        :first_name => 'Count',
        :last_name => 'Von Newsome',
        :roles_mask => 1,
        :password => 'thisisnotsecret', :password_confirmation => 'thisisnotsecret',
        :veteran_status => :newbie
      },
      {
        :email => 'author@iboard.cc',
        :name  => 'Author',
        :first_name => 'Arthur',
        :last_name => 'Authorus',
        :roles_mask => 2,
        :password => 'thisisnotsecret', :password_confirmation => 'thisisnotsecret'
      },
      {
        :email => 'moderator@iboard.cc',
        :name  => 'Moderator',
        :first_name => 'Drew',
        :last_name => 'Brackenstein',
        :roles_mask => 3,
        :password => 'thisisnotsecret', :password_confirmation => 'thisisnotsecret'
      },
      {
        :email => 'maintainer@iboard.cc',
        :name  => 'maintainer',
        :first_name => 'Marty',
        :last_name => 'Materian',
        :roles_mask => 4,
        :password => 'thisisnotsecret', :password_confirmation => 'thisisnotsecret'
      },
      {
        :email => 'staff@iboard.cc',
        :name  => 'staff',
        :first_name => 'Andre',
        :last_name => 'Staffson',
        :roles_mask => 4,
        :password => 'thisisnotsecret', :password_confirmation => 'thisisnotsecret'
      }
    ].each do |hash|
      user = User.create(hash)
      user.confirm!
      user.save!
      user.reload
      raise "NOT CONFIRMED!" unless user.confirmed?
    end
  end

  def add_a_bunch_of_health_conditions
    %w{
      history_of_heart_problems
      cigarette_cigar_or_pipe_smoking
      increased_blood_pressure
      increased_total_blood_cholesterol
      diabetes_mellitus
      heart_problems_chest_pain_or_stroke
      breathing_or_lung_problems
      muscle_joint_or_back_disorder
      hernia
      chronic_illness
      obesity
      recent_surgery
      pregnancy
      difficulty_with_physical_exercise
    }.each do |condition|
      FactoryGirl.create(:medical_condition, name: condition.humanize)
      puts "creating #{condition.humanize}"
    end
  end

  # Create a valid and visible posting for user with _email_
  # If blog 'News' doesn't exist, it will be created.
  # @param [String] email - use one of 'default_user_set'
  # @return [Posting]
  def create_posting_for(email,attributes={})
    user = User.where( :email => email).first
    attributes.merge! :user_id => user.id
    blog = Blog.first || Blog.create!(title: 'News', is_draft: false)
    posting = blog.postings.create(attributes)
    unless posting.valid?
      assert false, "#  New Posting has errors #{posting.errors.inspect}\n"
    end
    posting.save!
    blog.save!
    posting
  end

  # Do something (the block) with the user-object.
  # @param [String] email - use one of 'default_user_set'
  def with_user user_email, &block
    user = User.where(:email => user_email).first
    yield(user)
  end

  # Login
  # @param [String] user_email, use one of default_user_set
  # @param [String] password, is always hardcoded as 'thisisnotsecret'
  def log_in_as(user_email,password)
    with_user(user_email) do |user|
        visit "/users/sign_in"
        fill_in("Email", :with => user.email)
        fill_in("Password", :with => password)
        click_button("Sign in")
    end
  end

  # Log out
  def log_out
    click_link("Sign out")
  end

  # Create a default PageTemplate
  def create_default_page_template
    PageTemplate.create(:name => 'default')
  end

  # Create a page with one component
  # @param [Hash] options, The page attributes plus :page_component => attributes
  # @return [Page], the created page
  def create_page_with_component( options )
    component = options[:page_component]
    template = create_default_page_template
    component.merge! :page_template_id => template.id
    options.delete(:page_component)
    options.merge! :page_template_id => template.id
    page = Page.new(options)
    unless page.valid?
      puts "***** PAGE INVALID IN #{__FILE__}:#{__LINE__} - #{page.errors.inspect} *****"
    end
    page.page_components.create(component)
    page.save!
    page
  end

  # Create the first "News-Blog and yield the given block with the new item"
  # if no block given return the new item
  def create_news_blog_with_postings(&block)
    news_blog = Blog.find_or_create_by( title: 'News' )
    unless block_given?
      return news_blog
    end
    yield(news_blog)
  end

  # @param [String] path - the path of the file
  # @param [String] content - the content for the file
  # @return [Boolean] true if file was created before otherwise false
  def create_file_if_not_exists(path, content="")
    file_exists = File.exists?(path)
    unless file_exists
      f = File.open(path,"w")
      f << content
      f.close
      file_exists = true
    end
    file_exists
  end

  # @param [ActiveModel] item - The item to check if attributes changed
  # @param [Hash] saved_attributes - The attributes saved before an action
  # @return Boolean - true if any attribute is not equal.
  def attributes_changed?(item,saved_attributes)
    item.reload
    saved_attributes.delete('updated_at')
    saved_attributes.each do |key, value|
      return true unless item.attributes[key].eql?(value)
    end
    false
  end

  def random_time_in_the_future
    week_num = (rand(10) +1)
    day_num = (1+rand(30))
    hour_num = (1+rand(24))
    future_date = week_num.weeks.from_now
    Time.local(future_date.year,future_date.month,day_num, hour_num)
  end

  def random_time_in_the_past
    week_num = (rand(10) +1)+5
    hour_num = (1+rand(24))
    future_date = week_num.weeks.ago
    Time.local(future_date.year, future_date.month, future_date.day, hour_num)
  end

  def get_to_view_cart
    log_in_as "staff@iboard.cc", 'thisisnotsecret'
    visit fitness_camp_registration_all_fitness_camps_path
    click_on "6:00AM to 7:00AM"
    click_on "Checkout"
  end

  def get_to_consent
    get_to_view_cart
    click_button "Proceed to health consent"
    # then test some stuff
  end

  def get_to_release_and_waiver_of_liability
    get_to_consent
    choose("health_approval_participation_approved_yes")
    choose("health_approval_taking_medications_no")
    click_button "Proceed to Release and Waiver of Liability"
    # then test some stuff
  end

  def get_to_terms_of_participation
    get_to_release_and_waiver_of_liability
    check "agree_to_terms"
    click_button "Continue to Terms of Participation"    
    # then test some stuff
  end

  def get_to_payment
    get_to_terms_of_participation
    # then test some stuff
    check "agree_to_terms"
    click_button "Proceed to Payment"    
  end

  def create_15_users_and_workouts
    @fww = FactoryGirl.create(:fit_wit_workout, score_method: "simple-rounds", name: "cindy")
    the_high_score = (1..15).to_a
    the_low_score = the_high_score.map{|a| a - 1 }
    FactoryGirl.create_list(:user,15).each_with_index do |user, i|
      FactoryGirl.create(:workout, user: user, fit_wit_workout: @fww, score: the_high_score[i])
      FactoryGirl.create(:workout, user: user, fit_wit_workout: @fww, score: the_low_score[i])
    end
    u = FactoryGirl.create(:user, gender: :female, email: Faker::Internet.email)
    FactoryGirl.create(:workout, fit_wit_workout: @fww, user: u, score: "50")
  end

end
