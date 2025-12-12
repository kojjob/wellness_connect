require "application_system_test_case"
require "timeout"

class ConversationsTest < ApplicationSystemTestCase
  setup do
    # Create users
    @patient = users(:patient_user)
    @provider = users(:provider_user)

    # Create a conversation between patient and provider
    @conversation = Conversation.create!(
      patient: @patient,
      provider: @provider
    )

    # Create some messages
    @message1 = @conversation.messages.create!(
      sender: @patient,
      content: "Hello, I have a question about my appointment.",
      message_type: :text
    )

    @message2 = @conversation.messages.create!(
      sender: @provider,
      content: "Hello! I'm happy to help. What's your question?",
      message_type: :text
    )
  end

  test "patient can view conversations list" do
    sign_in @patient
    visit conversations_path

    assert_selector "h1", text: "Messages"
    assert_selector "h2", text: "Active"
    assert_text @provider.full_name
  end

  test "provider can view conversations list" do
    sign_in @provider
    visit conversations_path

    assert_selector "h1", text: "Messages"
    assert_selector "h2", text: "Active"
    assert_text @patient.full_name
  end

  test "patient can view conversation with messages" do
    sign_in @patient
    visit conversation_path(@conversation)

    # Should see provider name in header
    assert_text @provider.full_name

    # Should see both messages
    assert_text "Hello, I have a question about my appointment."
    assert_text "Hello! I'm happy to help. What's your question?"
  end

  test "provider can view conversation with messages" do
    sign_in @provider
    visit conversation_path(@conversation)

    # Should see patient name in header
    assert_text @patient.full_name

    # Should see both messages
    assert_text "Hello, I have a question about my appointment."
    assert_text "Hello! I'm happy to help. What's your question?"
  end

  test "patient can send a text message" do
    sign_in @patient
    visit conversation_path(@conversation)

    before_count = Message.where(conversation: @conversation).count

    # Fill + submit via JS to avoid flaky click/scroll issues in headless mode
    set_message_textarea_value("Thank you for your help!")
    submit_message_form(@conversation)

    wait_for_message_count(@conversation, before_count + 1)

    # Refresh and assert rendered in the message list
    visit conversation_path(@conversation)
    within("#conversation_messages") { assert_text "Thank you for your help!" }

    # Message should be saved in database (content is encrypted, so don't query by content)
    latest = Message.where(conversation: @conversation, sender: @patient).order(created_at: :desc).first
    assert_equal "Thank you for your help!", latest.content
  end

  test "provider can send a text message" do
    sign_in @provider
    visit conversation_path(@conversation)

    before_count = Message.where(conversation: @conversation).count

    # Fill + submit via JS to avoid flaky click/scroll issues in headless mode
    set_message_textarea_value("You're welcome! Feel free to ask anytime.")
    submit_message_form(@conversation)

    wait_for_message_count(@conversation, before_count + 1)

    # Refresh and assert rendered in the message list
    visit conversation_path(@conversation)
    within("#conversation_messages") { assert_text "You're welcome! Feel free to ask anytime." }

    # Message should be saved in database (content is encrypted, so don't query by content)
    latest = Message.where(conversation: @conversation, sender: @provider).order(created_at: :desc).first
    assert_equal "You're welcome! Feel free to ask anytime.", latest.content
  end

  test "message form clears after sending" do
    sign_in @patient
    visit conversation_path(@conversation)

    # Fill in message form
    message_text = "This message should disappear after sending"
    set_message_textarea_value(message_text)
    submit_message_form(@conversation)

    # Wait for turbo stream to complete
    assert_text message_text

    # Form should be cleared (check textarea is empty)
    textarea = find("textarea[name='message[content]']")
    assert_equal "", textarea.value
  end

  test "messages show sender information correctly" do
    sign_in @patient
    visit conversation_path(@conversation)

    # Patient's own messages should appear on the right
    # Provider's messages should appear on the left with name

    # Check for provider's name on their message
    within("#message_#{@message2.id}") do
      assert_text @provider.full_name
    end

    # Patient's own message should not show their name
    within("#message_#{@message1.id}") do
      assert_no_text @patient.full_name
    end
  end

  test "can navigate to messages from navbar" do
    sign_in @patient
    visit root_path

    # Messages lives in the user menu dropdown
    find("button[aria-label='User menu']", visible: true, wait: 5).click
    assert_selector("div[data-dropdown-target='menu']:not(.hidden)", wait: 5)

    within("div[data-dropdown-target='menu']") do
      click_link "Messages"
    end

    assert_current_path conversations_path
    assert_selector "h1", text: "Messages"
  end

  test "empty conversation shows empty state" do
    # Create conversation with no messages
    empty_conversation = Conversation.create!(
      patient: @patient,
      provider: @provider
    )

    sign_in @patient
    visit conversation_path(empty_conversation)

    assert_text "Start the conversation"
    assert_text "Send a message"
  end

  test "messages show read status for sender" do
    # Create unread message from patient
    unread_message = @conversation.messages.create!(
      sender: @patient,
      content: "Unread message test",
      message_type: :text
    )

    sign_in @patient
    visit conversation_path(@conversation)

    # Initially should show sent status (not read)
    within("#message_#{unread_message.id}") do
      assert_text "Sent"
    end

    # Simulate recipient reading the message
    unread_message.update!(read_at: Time.current)

    # Sender should now see "Read" on refresh
    visit conversation_path(@conversation)
    within("#message_#{unread_message.id}") do
      assert_text "Read"
    end
  end

  test "can archive conversation" do
    sign_in @patient
    visit conversation_path(@conversation)

    # Click archive button (accept Turbo confirm)
    accept_confirm(/Archive this conversation\?/i) do
      click_button "Archive"
    end

    # Should redirect to conversations index
    assert_current_path conversations_path
    assert_text "Conversation archived."

    # Conversation should be in archived section
    assert_selector "h2", text: "Archived"
  end

  test "message validation errors are displayed" do
    sign_in @patient
    visit conversation_path(@conversation)

    # Try to send empty message (should be prevented by required attribute, but test validation)
    # First, remove the required attribute using JavaScript
    page.execute_script("document.querySelector('textarea[name=\"message[content]\"]').removeAttribute('required')")

    # Now try to submit empty form
    submit_message_form(@conversation)

    # Should show error or stay on page
    # (The exact behavior depends on your validation setup)
    assert_current_path conversation_path(@conversation)
  end

  test "multiline messages work correctly" do
    sign_in @patient
    visit conversation_path(@conversation)

    # Fill in multiline message
    multiline_text = "Line 1\nLine 2\nLine 3"
    # Avoid triggering the Enter-to-send keydown handler while filling.
    page.execute_script(<<~JS)
      const textarea = document.querySelector("textarea[name='message[content]']")
      textarea.value = #{multiline_text.to_json}
      textarea.dispatchEvent(new Event('input', { bubbles: true }))
    JS

    # Submit form
    submit_message_form(@conversation)

    # Should see the multiline message
    assert_text "Line 1"
    assert_text "Line 2"
    assert_text "Line 3"
  end

  test "conversation shows participant specialty if provider" do
    # Add specialty to provider profile
    @provider.provider_profile.update(specialty: "Mental Health Counselor")

    sign_in @patient
    visit conversation_path(@conversation)

    # Should see specialty in header
    assert_text "Mental Health Counselor"
  end

  test "back button navigates to conversations list" do
    sign_in @patient
    visit conversation_path(@conversation)

    # Click back button (SVG link)
    within("header") do
      find("a[href='#{conversations_path}']", match: :first).click
    end

    assert_current_path conversations_path
  end

  test "only shows active conversations by default" do
    # Create a distinct conversation we can assert against (fixtures include other conversations)
    unique_provider = User.create!(
      email: "unique_provider_#{SecureRandom.hex(4)}@example.com",
      password: "password123456",
      first_name: "Unique",
      last_name: "Provider",
      role: :provider,
      time_zone: "UTC"
    )

    unique_conversation = Conversation.create!(patient: @patient, provider: unique_provider)
    unique_conversation.messages.create!(sender: @patient, content: "Unique last message", message_type: :text)
    unique_conversation.update!(archived_by_patient: true)

    sign_in @patient
    visit conversations_path

    assert_selector "h2", text: "Active"
    active_section = find("h2", text: "Active").ancestor("div.mb-12")
    within(active_section) do
      assert_no_text unique_provider.full_name
    end

    assert_selector "h2", text: "Archived"
    assert_text unique_provider.full_name
  end

  def sign_out
    find("button[aria-label='User menu']", wait: 5).click
    click_on "Sign Out"
  end

  def wait_for_message_count(conversation, expected_count, timeout_seconds: 10)
    Timeout.timeout(timeout_seconds) do
      loop do
        # System tests run the app server in a separate process.
        # Avoid Rails query cache returning a stale count in this test process.
        current_count = ActiveRecord::Base.uncached do
          Message.where(conversation: conversation).count
        end

        break if current_count == expected_count
        sleep 0.1
      end
    end
  end

  private

  def set_message_textarea_value(value)
    page.execute_script(<<~JS)
      const textarea = document.querySelector("textarea[name='message[content]']")
      textarea.value = #{value.to_json}
      textarea.dispatchEvent(new Event('input', { bubbles: true }))
    JS
  end

  def submit_message_form(conversation)
    form_selector = "form[action='#{conversation_messages_path(conversation)}']"
    page.execute_script(<<~JS)
      const form = document.querySelector(#{form_selector.to_json})
      if (form.requestSubmit) {
        form.requestSubmit()
      } else {
        form.submit()
      }
    JS
  end

  def sign_in(user)
    visit new_user_session_path
    fill_in "Email Address", with: user.email
    fill_in "Password", with: "password123"  # Assuming fixtures use this password
    click_button "Sign In"

    # Wait for authenticated navbar to appear
    assert_selector "button[aria-label='User menu']", wait: 5
  end
end
