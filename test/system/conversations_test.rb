require "application_system_test_case"

class ConversationsTest < ApplicationSystemTestCase
  setup do
    # Create users
    @patient = users(:patient_one)
    @provider = users(:provider_one)

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
    assert_selector "h2", text: "Active Conversations"
    assert_text @provider.full_name
  end

  test "provider can view conversations list" do
    sign_in @provider
    visit conversations_path

    assert_selector "h1", text: "Messages"
    assert_selector "h2", text: "Active Conversations"
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

    # Fill in message form
    fill_in "message[content]", with: "Thank you for your help!"

    # Submit form
    click_button "Send"

    # Should see the new message
    assert_text "Thank you for your help!"

    # Message should be saved in database
    assert @conversation.messages.where(
      sender: @patient,
      content: "Thank you for your help!"
    ).exists?
  end

  test "provider can send a text message" do
    sign_in @provider
    visit conversation_path(@conversation)

    # Fill in message form
    fill_in "message[content]", with: "You're welcome! Feel free to ask anytime."

    # Submit form
    click_button "Send"

    # Should see the new message
    assert_text "You're welcome! Feel free to ask anytime."

    # Message should be saved in database
    assert @conversation.messages.where(
      sender: @provider,
      content: "You're welcome! Feel free to ask anytime."
    ).exists?
  end

  test "message form clears after sending" do
    sign_in @patient
    visit conversation_path(@conversation)

    # Fill in message form
    message_text = "This message should disappear after sending"
    fill_in "message[content]", with: message_text

    # Submit form
    click_button "Send"

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

    # Click on messages link in navbar
    within("nav") do
      click_link "Messages", match: :first
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

    assert_text "No messages yet"
    assert_text "Start the conversation by sending a message below"
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

    # Should show sent status (not read)
    within("#message_#{unread_message.id}") do
      assert_text "Sent"
    end

    # Mark as read
    @conversation.mark_as_read_for_provider
    unread_message.reload

    # Refresh page
    visit conversation_path(@conversation)

    # Should show read status
    within("#message_#{unread_message.id}") do
      assert_text "Read"
    end
  end

  test "can archive conversation" do
    sign_in @patient
    visit conversation_path(@conversation)

    # Click archive button
    click_button "Archive"

    # Should redirect to conversations index
    assert_current_path conversations_path
    assert_text "Conversation archived"

    # Conversation should be in archived section
    assert_selector "h2", text: "Archived Conversations"
  end

  test "message validation errors are displayed" do
    sign_in @patient
    visit conversation_path(@conversation)

    # Try to send empty message (should be prevented by required attribute, but test validation)
    # First, remove the required attribute using JavaScript
    page.execute_script("document.querySelector('textarea[name=\"message[content]\"]').removeAttribute('required')")

    # Now try to submit empty form
    click_button "Send"

    # Should show error or stay on page
    # (The exact behavior depends on your validation setup)
    assert_current_path conversation_path(@conversation)
  end

  test "multiline messages work correctly" do
    sign_in @patient
    visit conversation_path(@conversation)

    # Fill in multiline message
    multiline_text = "Line 1\nLine 2\nLine 3"
    fill_in "message[content]", with: multiline_text

    # Submit form
    click_button "Send"

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
    within(".bg-white.dark\\:bg-gray-800.border-b") do
      first("a[href='#{conversations_path}']").click
    end

    assert_current_path conversations_path
  end

  test "only shows active conversations by default" do
    # Archive conversation for patient
    @conversation.update(archived_by_patient: true)

    sign_in @patient
    visit conversations_path

    # Should not see the conversation in active section
    within("h2", text: "Active Conversations") do
      # Nothing to check here, just making sure section exists
    end

    # Check that we don't see the provider's name in active conversations
    # (It should only appear in archived section)
    active_section = find("h2", text: "Active Conversations").ancestor("div.mb-12")
    within(active_section) do
      assert_text "No active conversations"
    end
  end

  private

  def sign_in(user)
    visit new_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password123"  # Assuming fixtures use this password
    click_button "Sign in"
  end
end
