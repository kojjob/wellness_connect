require "application_system_test_case"

class FlashMessagesTest < ApplicationSystemTestCase
  test "displays success flash message" do
    visit "/test_flash/success"

    assert_selector "[data-controller='toast']", text: "Success message", wait: 2
    assert_selector ".toast-success", wait: 2
  end

  test "displays error flash message" do
    visit "/test_flash/error"

    assert_selector "[data-controller='toast']", text: "Error message", wait: 2
    assert_selector ".toast-error", wait: 2
  end

  test "displays warning flash message" do
    visit "/test_flash/warning"

    assert_selector "[data-controller='toast']", text: "Warning message", wait: 2
    assert_selector ".toast-warning", wait: 2
  end

  test "displays info flash message" do
    visit "/test_flash/info"

    assert_selector "[data-controller='toast']", text: "Info message", wait: 2
    assert_selector ".toast-info", wait: 2
  end

  test "displays notice flash message" do
    visit "/test_flash/notice"

    assert_selector "[data-controller='toast']", text: "Notice message", wait: 2
    assert_selector ".toast-notice", wait: 2
  end

  test "manually dismisses toast message" do
    visit "/test_flash/success"

    assert_selector "[data-controller='toast']", text: "Success message", wait: 2

    within("[data-controller='toast']") do
      find("[data-action='click->toast#dismiss']").click
    end

    assert_no_selector "[data-controller='toast']", text: "Success message", wait: 2
  end

  test "auto-dismisses toast message after timeout" do
    visit "/test_flash/success"

    assert_selector "[data-controller='toast']", text: "Success message", wait: 2

    # Wait for auto-dismiss (5 seconds + 1 second buffer)
    assert_no_selector "[data-controller='toast']", text: "Success message", wait: 6
  end

  test "displays multiple flash messages" do
    visit "/test_flash/multiple"

    assert_selector "[data-controller='toast']", text: "First message", wait: 2
    assert_selector "[data-controller='toast']", text: "Second message", wait: 2
    assert_selector "[data-controller='toast']", text: "Third message", wait: 2
  end

  test "turbo stream flash integration" do
    visit "/test_flash/turbo_stream_flash"

    assert_selector "[data-controller='toast']", text: "Turbo Stream message", wait: 2
  end
end
