require File::expand_path('../../spec_helper', __FILE__)

# here is the flow
## registration/view_cart
# on this page:
#    | - can add a coupon
#    | - can pay by session
#    | - can empty cart
#    | - can join membership
#    | - can change status (vet, etc)
# ... when done verify price, proceed to health consent
## consent
# on this page:
#    | - update health history
#    | - check approvals
# ... then onto /registration/release_and_waiver_of_liability
## release_and_waiver_of_liability
#    | - must check the box to move on
## terms_of_participation
#    | - must check the box to move on
## payment/:order_id
#    | - must enter required fields
#    | - must submit payment

# seems like all views are there, let's create a skelton


describe "The user registration process" do

  before(:all) do
    cleanup_database
    create_default_userset
    six_am = Time.local(2000,1,1,6)
    seven_am = six_am + 1.hour
    #Capybara.current_driver = :selenium
    @fc = FactoryGirl.create(:a_camp)
    @fc.time_slots << [TimeSlot.new(start_time: six_am, end_time: seven_am), 
                      TimeSlot.new(start_time: six_am + 3.hours, end_time: six_am + 4.hours)]
    @fc2 = FactoryGirl.create(:a_camp)
    @fc2.time_slots << FactoryGirl.create(:six_am_sold_out, fitness_camp: @fc2)
    @cpn = FactoryGirl.create(:coupon_code)
    @cpn.expires_at = 10.weeks.from_now
    @cpn.save
  end

  it "should allow a non-registered user to add a class to their cart" do
    visit fitness_camp_registration_all_fitness_camps_path
    page.should have_content("To register for a camp")
    click_on "6:00AM to 7:00AM"
    # then you should see a flash telling you that you need to register
    page.should have_content("Total fitness camps")
    # can we test the session ?
  end

  it "should not allow a user to checkout without signing in" do
    visit fitness_camp_registration_all_fitness_camps_path
    click_on "6:00AM to 7:00AM"
    page.should have_content("Total fitness camps")
    click_on "Checkout"
    page.should have_content("cool quote about taking")
    page.should have_content("You need to sign in or sign up before continuing.")
    #visit user_session_path
    fill_in "Email", with: "admin@iboard.cc"
    fill_in "Password", with: "thisisnotsecret"
    click_button "Sign in"
    # TODO -- we should be back at the checkout page -- this involves devise routes . . . wait on this
    page.should have_content("Signed in successfully.")
  end

  context "if a newbie views their cart they " do
    before(:each) do
      log_in_as 'newbie@fitwit.com', 'thisisnotsecret'
      visit fitness_camp_registration_all_fitness_camps_path
      click_on "6:00AM to 7:00AM"
      click_on "Checkout"
      CouponCode.destroy_all
      @cpn = FactoryGirl.create(:coupon_code)
    end
    it "should show newbie information for a first time camper" do
      page.should have_content "If you have completed a Fitness Camp before"
    end
    it "should display the standard price cart after a user clicks checkout" do
      page.should have_content "You are registering for the following fitness camp:"
      page.should have_content "Standard price:$299.00"
      page.should have_content "Final Price$299.00"
    end
    it "should let them add and remove a friend", js: true do
      fill_in "friend_name", with: "Jason"
      click_on "Add friend"
      page.should have_content "Jason"
      # now remove Jason
      click_on "oops, remove Jason"
      page.should_not have_content "Discount for Jason"
    end

    it "should let them add a valid coupon", js: true do
      @cpn.expires_at = 10.weeks.from_now
      @cpn.save
      fill_in "coupon_code", with: @cpn.code
      click_on "Add coupon"
      page.should have_content "Coupon code #{@cpn.code}"
    end

    describe "should not accept a bogus coupon and specifically " do
      it "should reject an invalid coupon code", js: true do
        fill_in "coupon_code", with: "bad cat"
        click_on "Add coupon"
        page.should have_content "That code was not found"
      end
      it "should reject an expired coupon code", js: true do
        @cpn.expires_at = 10.weeks.ago
        @cpn.save
        fill_in "coupon_code", with: @cpn.code
        click_on "Add coupon"
        page.should have_content "Sorry, that code has expired"
      end
      it "should reject an overused coupon code", js: true do
        @cpn.expires_at = 10.weeks.from_now
        @cpn.uses = 11
        @cpn.max_uses = 10
        @cpn.save
        fill_in "coupon_code", with: @cpn.code
        click_on "Add coupon"
        page.should have_content "Sorry, that code has been used the maximum number of times"
        #sleep(5)
        # should we check the cart price for no change
      end
      it "should reject an inactive coupon code", js: true do
        @cpn.expires_at = 10.weeks.from_now
        @cpn.active = false
        @cpn.save
        fill_in "coupon_code", with: @cpn.code
        click_on "Add coupon"
        page.should have_content "Sorry, that code is no longer active"
        #sleep()
      end
    end

    it "should be able to correct their veteran status" do
      pending
    end
  end

#
#  it "should show take a user through the most benign registration process" do
#    log_in_as "staff@iboard.cc", 'thisisnotsecret'
#    visit fitness_camp_registration_all_fitness_camps_path
#    click_on "6:00AM to 7:00AM"
#    click_on "Checkout"
#    #visit fitness_camp_registration_view_cart_path
#    click_button "Proceed to health consent"
#    page.should have_content "Registration step 3 of 6"
#    # now check the right boxes
#    choose("health_approval_participation_approved_yes")
#    choose("health_approval_taking_medications_no")
#    click_button "Proceed to Release and Waiver of Liability"
#    page.should have_content "Release and Waiver of Liability: Registration step 4 of 6"
#    check "agree_to_terms"
#    click_button "Continue to Terms of Participation"
#    check "agree_to_terms"
#    click_button "Proceed to Payment"
#    page.should have_content "Complete Payment: Registration step 6 of 6"
#    # success !!!!
#  end
#
#  it "should not allow any users to register without agreeing to release_and_waiver_of_liability" do
#    pending "until i can get the cart_view working"
##    log_in_as "admin@iboard.cc", 'thisisnotsecret'
# #   visit
#  end
#
#  it "should let you change a veterans status on the view cart page" do
#    get_to_view_cart
#  end
#
#  it "should not allow any users to register without agreeing to rules" do
#    pending
#  end
#
#  it "can add a coupon" do
#    pending "until we get the full coupon logic flushed out"
#  end
#
#  it "can pay by session" do
#    pending "until we can get the full pay by session implemented"
#  end
#
#  it "can empty cart" do
#    pending "until we have the cart functionality fully tested"
#  end
#
#  it "can join membership" do
#    pending " until we have the membership fully configured"
#  end
#
#  it "can change status (vet, etc)" do
#    pending " until the status functionality is there"
#  end
#
#  it "should only show the user future fitness camps" do
#    pending
#  end
#
#  it "should show sold out camps without a button" do
#    pending
#  end
#
#  it "should let a user empty the cart and start over" do
#    pending
#  end
#
#  it "should be able to submit payment" do
#    get_to_payment
#    page.should have_content "Complete Payment"
#    # works!
#  end

end
