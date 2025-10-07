// Load all the channels within this directory and all subdirectories.
// Channel files must be named *_channel.js.

import { createConsumer } from "@rails/actioncable"

// Create the Action Cable consumer
export const consumer = createConsumer()

// Import all channel files
const channels = import.meta.glob('./**/*_channel.js', { eager: true })
