import { consumer } from "./index"

// Subscribe to ConversationChannel for a specific conversation
export function subscribeToConversation(conversationId) {
  return consumer.subscriptions.create(
    { channel: "ConversationChannel", id: conversationId },
    {
      // Called when subscription is ready
      connected() {
        console.log(`Connected to conversation ${conversationId}`)
      },

      // Called when subscription is closed
      disconnected() {
        console.log(`Disconnected from conversation ${conversationId}`)
      },

      // Called when data is received from the server
      received(data) {
        console.log("Received data:", data)

        switch(data.type) {
          case "message":
            this.handleNewMessage(data)
            break
          case "typing":
            this.handleTypingIndicator(data)
            break
          case "presence":
            this.handlePresenceUpdate(data)
            break
          default:
            console.warn("Unknown data type:", data.type)
        }
      },

      // Handle new message broadcast
      handleNewMessage(data) {
        // Turbo Streams will handle this automatically via the Message model's broadcast
        // This is here as a fallback or for additional client-side processing
        console.log("New message received:", data)

        // Optional: Scroll to bottom when new message arrives
        const messagesContainer = document.getElementById("conversation_messages")
        if (messagesContainer) {
          setTimeout(() => {
            messagesContainer.scrollTop = messagesContainer.scrollHeight
          }, 100)
        }

        // Optional: Play notification sound
        // this.playNotificationSound()
      },

      // Handle typing indicator
      handleTypingIndicator(data) {
        const typingIndicator = document.getElementById("typing_indicator")

        if (!typingIndicator) {
          // Create typing indicator if it doesn't exist
          this.createTypingIndicator()
        }

        const indicator = document.getElementById("typing_indicator")

        if (data.is_typing) {
          // Show typing indicator
          indicator.textContent = `${data.user_name} is typing...`
          indicator.classList.remove("hidden")
        } else {
          // Hide typing indicator
          indicator.classList.add("hidden")
        }
      },

      // Handle presence updates
      handlePresenceUpdate(data) {
        const presenceIndicator = document.getElementById("presence_indicator")

        if (!presenceIndicator) {
          // Create presence indicator if it doesn't exist
          this.createPresenceIndicator()
        }

        const indicator = document.getElementById("presence_indicator")

        if (data.status === "online") {
          // Show online status
          indicator.innerHTML = `
            <span class="inline-flex items-center px-2 py-1 text-xs font-medium text-green-700 bg-green-100 rounded-full dark:bg-green-900 dark:text-green-300">
              <span class="w-2 h-2 mr-1 bg-green-500 rounded-full"></span>
              Online
            </span>
          `
          indicator.classList.remove("hidden")
        } else {
          // Show offline status
          indicator.innerHTML = `
            <span class="inline-flex items-center px-2 py-1 text-xs font-medium text-gray-700 bg-gray-100 rounded-full dark:bg-gray-700 dark:text-gray-300">
              <span class="w-2 h-2 mr-1 bg-gray-400 rounded-full"></span>
              Offline
            </span>
          `
        }
      },

      // Create typing indicator element
      createTypingIndicator() {
        const messagesContainer = document.getElementById("conversation_messages")
        if (messagesContainer && !document.getElementById("typing_indicator")) {
          const indicator = document.createElement("div")
          indicator.id = "typing_indicator"
          indicator.className = "hidden text-sm text-gray-500 dark:text-gray-400 italic px-4 py-2"
          messagesContainer.insertAdjacentElement('afterend', indicator)
        }
      },

      // Create presence indicator element
      createPresenceIndicator() {
        const conversationHeader = document.querySelector(".flex.items-center.justify-between")
        if (conversationHeader && !document.getElementById("presence_indicator")) {
          const indicator = document.createElement("div")
          indicator.id = "presence_indicator"
          indicator.className = "ml-2"

          // Insert after the participant info
          const participantInfo = conversationHeader.querySelector("div > div")
          if (participantInfo) {
            participantInfo.appendChild(indicator)
          }
        }
      },

      // Send typing notification to server
      typing(isTyping) {
        this.perform("typing", { is_typing: isTyping })
      },

      // Optional: Play notification sound
      playNotificationSound() {
        // Implement if needed
        // const audio = new Audio('/sounds/notification.mp3')
        // audio.play()
      }
    }
  )
}

// Auto-subscribe when the page loads if we're on a conversation show page
document.addEventListener("turbo:load", () => {
  const conversationElement = document.querySelector("[data-conversation-id]")

  if (conversationElement) {
    const conversationId = conversationElement.dataset.conversationId

    // Unsubscribe from previous subscription if any
    if (window.conversationSubscription) {
      window.conversationSubscription.unsubscribe()
    }

    // Create new subscription and store it globally
    window.conversationSubscription = subscribeToConversation(conversationId)

    // Setup typing indicator for the message textarea
    const messageTextarea = document.getElementById("message_content")
    if (messageTextarea) {
      let typingTimeout

      messageTextarea.addEventListener("input", () => {
        // Clear existing timeout
        clearTimeout(typingTimeout)

        // Send typing notification
        window.conversationSubscription.typing(true)

        // Stop typing after 2 seconds of inactivity
        typingTimeout = setTimeout(() => {
          window.conversationSubscription.typing(false)
        }, 2000)
      })

      // Stop typing when user focuses out
      messageTextarea.addEventListener("blur", () => {
        clearTimeout(typingTimeout)
        window.conversationSubscription.typing(false)
      })
    }
  }
})

// Cleanup on page unload
document.addEventListener("turbo:before-visit", () => {
  if (window.conversationSubscription) {
    window.conversationSubscription.unsubscribe()
    window.conversationSubscription = null
  }
})
