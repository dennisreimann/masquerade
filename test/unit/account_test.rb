require File.dirname(__FILE__) + '/../test_helper'

class AccountTest < ActiveSupport::TestCase  
  fixtures :accounts
  
  def setup
    @account = Account.new valid_account_attributes
  end
  
  def test_should_initialize_activation_code_upon_creation
    @account.save
    assert_not_nil @account.reload.activation_code
  end
  
  def test_should_require_login
    @account.login = nil
    assert_invalid @account, :login
  end
  
  def test_should_require_login_with_minimum_length_of_3_characters
    @account.login = "de"
    assert_invalid @account, :login
  end

  def test_should_require_login_without_whitespaces
    @account.login = "Tester Test"
    assert_invalid @account, :login
  end

  def test_should_require_login_without_umlauts
    @account.login = "Täster"
    assert_invalid @account, :login
  end
  
  def test_should_require_email
    @account.email = nil
    assert_invalid @account, :email
  end
  
  def test_should_require_valid_email
    @account.email = "test"
    assert_equal false, @account.valid?
    assert @account.errors.on(:email)
    @account.email = "test@hotmail"
    assert_equal false, @account.valid?
    assert @account.errors.on(:email)
    @account.email = "test@bla.com"
    assert_valid @account
  end
  
  def test_should_require_password
    @account.password = nil
    assert_invalid @account, :password
  end

  def test_should_require_password_confirmation
    @account.password_confirmation = nil
    assert_invalid @account, :password_confirmation
    valid_password = "1234567"
    @account.password = valid_password
    @account.password_confirmation = "123456"
    assert_invalid @account, :password
    @account.password_confirmation = valid_password
    assert_valid @account
  end

  def test_should_require_password_with_minimum_length_of_6_characters
    @account.password = "dere8"
    assert_invalid @account, :password
    valid_password = "dere84"
    @account.password = valid_password
    @account.password_confirmation = valid_password
    assert_valid @account
  end
  
  def test_should_assign_activation_code_on_create
    @account.save
    assert_not_nil @account.activation_code
  end
  
  def test_should_find_and_activate_by_activation_token
    @account.save
    assert_equal false, @account.active?
    Account.find_and_activate!(@account.reload.activation_code)
    @account.reload
    assert_equal true, @account.active?
    assert_not_nil @account.activated_at
  end
  
  def test_should_reset_password
    accounts(:standard).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal accounts(:standard), Account.authenticate('quentin', 'new password')
  end

  def test_should_not_rehash_password
    accounts(:standard).update_attributes(:login => 'quentin2')
    assert_equal accounts(:standard), Account.authenticate('quentin2', 'test')
  end

  def test_should_authenticate_user
    assert_equal accounts(:standard), Account.authenticate('quentin', 'test')
  end

  def test_should_set_remember_token
    accounts(:standard).remember_me
    assert_not_nil accounts(:standard).remember_token
    assert_not_nil accounts(:standard).remember_token_expires_at
  end

  def test_should_unset_remember_token
    accounts(:standard).remember_me
    assert_not_nil accounts(:standard).remember_token
    accounts(:standard).forget_me
    assert_nil accounts(:standard).remember_token
  end

  def test_should_remember_me_for_one_week
    before = 1.week.from_now.utc
    accounts(:standard).remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil accounts(:standard).remember_token
    assert_not_nil accounts(:standard).remember_token_expires_at
    assert accounts(:standard).remember_token_expires_at.between?(before, after)
  end

  def test_should_remember_me_until_one_week
    time = 1.week.from_now.utc
    accounts(:standard).remember_me_until time
    assert_not_nil accounts(:standard).remember_token
    assert_not_nil accounts(:standard).remember_token_expires_at
    assert_equal accounts(:standard).remember_token_expires_at, time
  end

  def test_should_remember_me_default_two_weeks
    before = 2.weeks.from_now.utc
    accounts(:standard).remember_me
    after = 2.weeks.from_now.utc
    assert_not_nil accounts(:standard).remember_token
    assert_not_nil accounts(:standard).remember_token_expires_at
    assert accounts(:standard).remember_token_expires_at.between?(before, after)
  end
  
  def test_should_delete_associated_personas_on_destroy
    @account.save
    @persona = @account.personas.create(valid_persona_attributes)
    assert_equal 1, @account.personas.size
    @account.destroy
    assert_nil Persona.find_by_id(@persona.id)
  end
  
  def test_should_delete_associated_sites_on_destroy
    @account.save
    @site = @account.sites.create(valid_site_attributes)
    assert_equal 1, @account.sites.size
    @account.destroy
    assert_nil Site.find_by_id(@site.id)
  end
  
  def test_should_get_associated_with_a_yubikey_if_the_given_otp_is_correct
    @account = accounts(:standard)
    yubico_otp = 'x' * 44
    assert @account.yubico_identity.nil?
    Account.expects(:verify_yubico_otp).with(yubico_otp).returns(true)
    @account.associate_with_yubikey(yubico_otp)
    @account.reload
    assert_equal yubico_otp[0..11], @account.yubico_identity
  end
  
  def test_should_be_able_to_authenticate_with_a_yubikey_if_it_matches_the_yubico_identity
    @account = accounts(:standard)
    yubico_otp = 'x' * 44
    @account.yubico_identity = yubico_otp[0..11]
    assert @account.save
    Account.expects(:verify_yubico_otp).with(yubico_otp).returns(true)
    assert @account.yubikey_authenticated?(yubico_otp)
  end
  
  def test_should_not_be_able_to_authenticate_with_a_yubikey_if_it_does_not_match_the_yubico_identity
    @account = accounts(:standard)
    yubico_otp = 'x' * 44
    @account.yubico_identity = 'y' * 12
    assert @account.save
    Account.expects(:verify_yubico_otp).with(yubico_otp).returns(true)
    assert !@account.yubikey_authenticated?(yubico_otp)
  end
  
  def test_should_split_password_and_yubico_otp
    password, yubico_otp = '123456', ('x' * 22 + 'y' * 22)
    token = password + yubico_otp
    assert_equal [password, yubico_otp], Account.split_password_and_yubico_otp(token)
  end
  
end
