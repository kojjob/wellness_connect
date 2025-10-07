# WellnessConnect - Project TODO List

## Messaging System Enhancements

**📋 Analysis Complete:** See `MESSAGING_ANALYSIS.md` for detailed findings and patterns to follow

### Priority 1: Action Cable Real-Time Integration (2-3 days)
**Leverage:** solid_cable (installed), cable.yml (configured), cable_schema.rb (exists)

- [x] Create `app/channels/application_cable/connection.rb` with authentication
- [x] Create `app/channels/conversation_channel.rb`
- [ ] Add JavaScript consumer in `app/javascript/channels/conversation_channel.js`
- [ ] Complete broadcast_message callback in Message model
- [ ] Implement typing indicators using Action Cable
- [ ] Add online/offline presence detection
- [ ] Write comprehensive tests for real-time features (follow existing test patterns)

### Priority 2: Enhanced Attachment Handling (1-2 days)
**Follow Pattern:** `app/models/provider_profile.rb` (lines 28-102)

- [ ] Add `validate :attachment_validation` to Message model
- [ ] Implement validation method following ProviderProfile pattern
- [ ] File type validation (images: JPEG/PNG/WebP, documents: PDF)
- [ ] File size limits (images: 10MB, documents: 20MB)
- [ ] Update MessagesController to handle attachments properly
- [ ] Create image preview in message bubbles (using existing AWS S3 integration)
- [ ] Add attachment download tracking
- [ ] Write attachment validation tests

### Priority 3: Message Search & Filtering (2 days)
**Start With:** ILIKE pattern (provider_profiles_controller.rb:8-14), **Upgrade To:** pg_search gem

- [ ] Add `gem 'pg_search'` to Gemfile and bundle install
- [ ] Add pg_search_scope to Message model
- [ ] Add search parameter handling in ConversationsController
- [ ] Create search UI components (follow existing filter pattern)
- [ ] Add filtering by date range (follow provider_profiles pattern)
- [ ] Add filtering by sender
- [ ] Add filtering by message type
- [ ] Implement search results highlighting
- [ ] Add conversation-specific search
- [ ] Add caching for search filters (Rails.cache.fetch pattern, 1 hour expiry)
- [ ] Add GIN index for full-text search performance

### Priority 4: User Experience Improvements (2-3 days)
**Reuse:** toast_controller.js, dropdown_controller.js, existing Tailwind patterns

- [ ] Add message reactions (emoji responses) - New Stimulus controller
- [ ] Implement message threading/replies - Extend Message model with parent_id
- [ ] Add bulk message operations - Follow existing checkbox selection pattern
- [ ] Create export conversation history feature (PDF/CSV) - New service object
- [ ] Add message templates for common responses - New model + UI
- [ ] Ensure dark mode support for all new components

### Priority 5: Advanced Features (3-4 days)
**Follow:** Existing tagging/categorization patterns if any

- [ ] Implement conversation labels/categories - acts_as_taggable or custom
- [ ] Add scheduled messages - Use Solid Queue (already installed)
- [ ] Create message forwarding feature - New action in MessagesController
- [ ] Add rich text formatting support (ActionText/Trix editor)
- [ ] Follow existing authorization patterns for all new features

---

## Implementation Notes

**Total Estimated Time:** 10-14 days for complete implementation

**Approach:**
- Test-Driven Development (TDD) with comprehensive test coverage
- Feature flags for gradual rollout
- Backward compatibility maintained
- Performance optimization with database indexes

**Current Status:**
- ✅ Basic messaging system complete (encryption, read receipts, edit window)
- ✅ Turbo Stream real-time updates working
- ✅ File attachment support via ActiveStorage
- ✅ Archive and unread count tracking implemented
- ✅ Action Cable connection and channel created with authentication
- ⚠️ JavaScript consumer pending
- ⚠️ Advanced features not yet implemented

**Branch Strategy:**
- Create feature branches for each priority group
- Test thoroughly before merging to main
- Use PR reviews for quality assurance

---

## Code Duplication Prevention

**Before implementing ANY feature, consult `MESSAGING_ANALYSIS.md` for:**

### Infrastructure Already Available
✅ solid_cable (Action Cable adapter)
✅ turbo-rails (real-time updates)
✅ stimulus-rails (JavaScript behavior)
✅ kaminari (pagination)
✅ pundit (authorization)
✅ aws-sdk-s3 (file storage)
✅ devise (authentication)

❌ pg_search (needs installation for full-text search)

### Patterns to Follow

**Attachment Validation:**
- Pattern: `app/models/provider_profile.rb:28-102`
- Size limits: Images 10MB, Documents 20MB
- Content types: Whitelist approach
- Error messages: Clear and user-friendly

**Search Implementation:**
- Basic: ILIKE pattern from `provider_profiles_controller.rb:8-14`
- Advanced: pg_search gem with PostgreSQL full-text search
- Caching: `Rails.cache.fetch(key, expires_in: 1.hour)`
- Filters: Follow provider_profiles multi-filter pattern

**Stimulus Controllers:**
- Pattern: All controllers in `app/javascript/controllers/`
- Reuse: toast_controller.js, dropdown_controller.js
- Structure: targets, values, connect(), actions

**Authorization:**
- Pattern: Pundit throughout application
- Usage: `authorize @resource` in controllers
- Scopes: `policy_scope(Resource)` for collections

**UI/UX:**
- CSS: Tailwind classes (consistent patterns)
- Dark mode: All components need `dark:` variants
- Responsive: Mobile-first with breakpoints
- Buttons: `bg-primary-600 hover:bg-primary-700`

**Database:**
- Indexes: Foreign keys + frequently queried columns
- Constraints: Check constraints for data integrity
- N+1 Prevention: `.includes()` for associations

**Testing:**
- Structure: Model, Controller, System tests
- Coverage: Happy path + error conditions + edge cases
- Pattern: Follow existing test structure in test/

### Quick Check Before Coding

- [ ] Is this gem already installed?
- [ ] Does similar code exist elsewhere?
- [ ] Am I following existing patterns?
- [ ] Do I need new patterns or can I adapt existing?
- [ ] Are validations consistent with other models?
- [ ] Is authorization following Pundit conventions?
- [ ] Am I using existing Stimulus controllers?
- [ ] Does UI match Tailwind patterns?
- [ ] Have I prevented N+1 queries?
- [ ] Are tests following existing structure?

**Key Principle:** Extend existing patterns, don't invent new ones!
