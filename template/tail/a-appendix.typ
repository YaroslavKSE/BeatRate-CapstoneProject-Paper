#import "@preview/hei-synd-thesis:0.1.1": *
#import "../metadata.typ": *
#pagebreak()
= #i18n("appendix-title", lang: option.lang) <sec:appendix>

== Test Cases Documentation

This appendix provides detailed documentation of all manual test cases executed during the validation process. Each test case includes specific objectives, step-by-step procedures, expected results, and actual outcomes that validate the functional and non-functional requirements of the BeatRate platform.

=== FR1: User Authentication and Profile Management Test Cases

==== Test Case 1.1: User Registration Flow

#colorbox(
  title: "Test Case 1.1: Email/Password Registration",
  color: color-info,
)[
*Objective:* Validate new user registration with email/password authentication

*Test Steps:*
1. Navigate to registration page (`/register`)
2. Enter valid email address (e.g., `test@example.com`)
3. Enter password meeting security requirements (min 8 characters, uppercase, number, special character)
4. Enter unique username (e.g., `testuser2024`)
5. Enter first name and surname
6. Submit registration form
7. Verify Auth0 user creation in Auth0 dashboard
8. Verify local database user record creation
9. Verify welcome email receipt
10. Confirm automatic login and redirect to dashboard

*Expected Result:* User successfully registered, Auth0 user created, local database record created, user logged in and redirected

*Actual Result:* ✅ PASS - Registration completes successfully

*Validation Method:* Manual testing + Auth0 dashboard verification + PostgreSQL database query
]

==== Test Case 1.2: Google OAuth Authentication

#colorbox(
  title: "Test Case 1.2: Google Social Login",
  color: color-info,
)[
*Objective:* Validate social login via Google OAuth integration

*Test Steps:*
1. Navigate to login page (`/login`)
2. Click "Sign in with Google" button
3. Complete Google OAuth consent flow in popup window
4. Verify automatic user profile creation from Google data
5. Confirm Auth0 user creation with Google identity
6. Verify local database user record creation with Google profile data
7. Confirm automatic login and redirect to dashboard
8. Verify profile populated with Google avatar and name

*Expected Result:* Seamless authentication, profile creation from Google data, successful login

*Actual Result:* ✅ PASS - Google authentication works correctly, profile data populated automatically

*Validation Method:* Manual testing + Auth0 logs analysis + database verification
]

==== Test Case 1.3: Profile Customization

#colorbox(
  title: "Test Case 1.3: User Profile Management",
  color: color-info,
)[
*Objective:* Validate comprehensive profile customization functionality

*Test Steps:*
1. Navigate to profile page (`/profile`)
2. Upload new profile avatar image (test with .jpg, .png formats)
3. Verify avatar upload to AWS S3 bucket
4. Edit bio text (test with special characters and emoji)
5. Update personal information (name, surname)
6. Add favorite artists by searching Spotify catalog
7. Add favorite albums from search results
8. Add favorite genres from predefined list
9. Reorder favorite items using drag-and-drop
10. Save all changes
11. Refresh page to verify persistence
12. Log out and log back in to confirm data retention

*Expected Result:* All profile changes saved and displayed correctly, data persists across sessions

*Actual Result:* ✅ PASS - All profile features function correctly, S3 upload successful

*Validation Method:* Manual testing + AWS S3 bucket verification + PostgreSQL database queries
]

=== FR2: Dual Rating System Test Cases

==== Test Case 2.1: Simple Rating System

#colorbox(
  title: "Test Case 2.1: Basic 1-10 Rating Submission",
  color: color-info,
)[
*Objective:* Validate basic rating system functionality and data persistence

*Test Steps:*
1. Navigate to track or album page (e.g., `/track/6qYkmqFsXbj8CQjAdbYz07`)
2. Click "Add Interaction" button to open rating modal
3. Select "Listened" checkbox to enable rating
4. Use slider interface to select rating (test values: 1, 5, 8, 10)
5. Optionally add review text
6. Submit rating interaction
7. Verify rating appears on track/album page
8. Check rating contributes to aggregate statistics
9. Verify rating appears in user's diary/profile
10. Test rating update by submitting new rating for same item
11. Verify only most recent rating is active

*Expected Result:* Rating saved correctly, contributes to statistics, appears in user history

*Actual Result:* ✅ PASS - Simple ratings work correctly, normalization to 1-10 scale functions properly

*Validation Method:* Manual testing + PostgreSQL database verification + statistics validation
]

==== Test Case 2.2: Complex Grading System

#colorbox(
  title: "Test Case 2.2: Multi-Component Rating Calculation",
  color: color-info,
)[
*Objective:* Validate complex grading system with hierarchical calculations

*Test Steps:*
1. Navigate to grading methods page (`/grading-methods/create`)
2. Create new complex grading template with multiple components:
   - Production Quality (weight: 30%)
   - Songwriting (weight: 40%)
   - Performance (weight: 30%)
3. Add sub-components to each main component (e.g., Mixing, Mastering under Production)
4. Define mathematical operations (addition, multiplication, weighted average)
5. Save grading template to MongoDB
6. Navigate to music item and select "Complex Grading"
7. Choose created grading template
8. Input grades for each component (test with various values)
9. Verify automatic hierarchical calculation
10. Submit complex rating
11. Verify storage in PostgreSQL with MongoDB template reference
12. Test template reusability by applying to different music item

*Expected Result:* Complex grades calculate correctly using defined formulas, template reusability works

*Actual Result:* ✅ PASS - Complex grading system functions as designed, calculations accurate

*Validation Method:* Manual testing + calculation verification + MongoDB template storage + PostgreSQL rating storage
]

=== FR3: Music Catalog Integration Test Cases

==== Test Case 3.1: Spotify API Integration

#colorbox(
  title: "Test Case 3.1: Music Search and Metadata Retrieval",
  color: color-info,
)[
*Objective:* Validate Spotify API integration, caching, and fallback mechanisms

*Test Steps:*
1. Perform music search using search interface (test queries: "weeknd", "quuen", "Bohemian Rhapsody")
2. Verify Spotify API data retrieval and response formatting
3. Check automatic caching to Redis (verify cache hits on repeated searches)
4. Verify MongoDB storage of retrieved data with expiration timestamps
5. Test with new releases and obscure tracks
6. Simulate Spotify API unavailability (temporarily block API endpoint)
7. Verify fallback to local MongoDB cache
8. Test local search functionality during API outage
9. Restore API access and verify fresh data retrieval
10. Validate metadata accuracy (track duration, artist names, album info)
11. Test audio preview playback functionality
12. Verify image URL handling and thumbnail optimization

*Expected Result:* Accurate music data with intelligent caching, reliable fallback during API issues

*Actual Result:* ✅ PASS - Catalog integration works reliably, fallback mechanisms effective

*Validation Method:* Manual testing + Redis cache inspection + MongoDB verification + API response logging
]

==== Test Case 3.2: Cache Performance and Fallback

#colorbox(
  title: "Test Case 3.2: Multi-Level Caching Strategy Validation",
  color: color-info,
)[
*Objective:* Validate three-tier caching performance and graceful degradation

*Test Steps:*
1. Clear all caches (Redis and MongoDB)
2. Request track data and measure initial response time (Spotify API call)
3. Immediately repeat request and verify Redis cache hit (< 100ms response)
4. Wait for Redis TTL expiration, request again to test MongoDB cache
5. Simulate Redis unavailability, verify MongoDB fallback
6. Simulate both Redis and Spotify unavailability, verify stale data serving
7. Measure performance differences between cache levels
8. Test concurrent request handling and cache consistency

*Expected Result:* Sub-100ms responses for cached data, graceful degradation maintains functionality

*Actual Result:* ✅ PASS - Cache strategy provides high availability, performance targets met

*Validation Method:* Performance monitoring + cache inspection + availability testing
]

=== FR4: Social Interaction Features Test Cases

==== Test Case 4.1: User Following System

#colorbox(
  title: "Test Case 4.1: Follow/Unfollow User Workflow",
  color: color-info,
)[
*Objective:* Validate social relationship management and activity feeds

*Test Steps:*
1. Navigate to people/users discovery page (`/people`)
2. Search for users using username/name search functionality
3. Select user to follow from search results
4. Click "Follow" button and verify immediate UI update
5. Check follower/following counters update correctly
6. Verify relationship creation in PostgreSQL database
7. Navigate to followed user's profile to confirm following status
8. Check activity feed updates to include followed user's interactions
9. Test unfollow functionality - click "Unfollow" button
10. Verify relationship removal from database
11. Confirm activity feed no longer shows unfollowed user's activity
12. Test edge cases: self-follow prevention, duplicate follow prevention

*Expected Result:* Social relationships managed correctly, activity feeds update appropriately

*Actual Result:* ✅ PASS - Social features function correctly, relationships persist properly

*Validation Method:* Manual testing + PostgreSQL relationship verification + activity feed validation
]

==== Test Case 4.2: Review and Rating Social Interactions

#colorbox(
  title: "Test Case 4.2: Like and Comment System",
  color: color-info,
)[
*Objective:* Validate social interaction with user-generated content

*Test Steps:*
1. Navigate to interaction page with detailed review
2. Test review like functionality - click heart icon
3. Verify like counter increments immediately
4. Verify like persistence in database
5. Add comment to review using comment interface
6. Verify comment appears immediately below review
7. Test comment editing and deletion functionality
8. Add reply to existing comment (if implemented)
9. Test comment like functionality
10. Verify hot score recalculation based on engagement

*Expected Result:* All social interactions function smoothly, engagement affects content ranking

*Actual Result:* ✅ PASS - Social interaction features work correctly, hot score updates properly

*Validation Method:* Manual testing + database verification + hot score calculation validation
]

=== FR5: Music List Management Test Cases

==== Test Case 5.1: List Creation and Management

#colorbox(
  title: "Test Case 5.1: Custom Music List Creation",
  color: color-info,
)[
*Objective:* Validate comprehensive list management functionality

*Test Steps:*
1. Navigate to lists page (`/lists`)
2. Click "Create List" button
3. Enter list title and description (test with special characters)
4. Select list type (ranked/unranked, albums/tracks/mixed)
5. Set visibility (public/private)
6. Save initial list configuration
7. Add tracks to list using search functionality
8. Test drag-and-drop reordering of list items
9. Verify position numbers update correctly after reordering
10. Add duplicate item and verify prevention mechanism
11. Remove items from list using delete functionality
12. Share list via public URL
13. Test list discovery in public lists section

*Expected Result:* Lists created, managed, and shared successfully with all features working

*Actual Result:* ✅ PASS - List management works correctly, all features functional

*Validation Method:* Manual testing + PostgreSQL database verification + list sharing validation
]

=== Non-Functional Requirements Test Cases

==== Test Case P1: Page Load Performance

#colorbox(
  title: "Test Case P1: Dashboard Load Performance",
  color: color-info,
)[
*Objective:* Validate page load performance meets requirements

*Test Steps:*
1. Clear browser cache and cookies
2. Navigate to login page and authenticate
3. Measure time from dashboard URL request to interactive content
4. Use Chrome DevTools Performance tab to analyze loading phases
5. Measure Core Web Vitals (LCP, FID, CLS)
6. Verify all API calls complete successfully
7. Check for any performance bottlenecks or slow queries
8. Test with different user data volumes (new user vs. heavy user)
9. Measure subsequent navigation performance (cached experience)

*Expected Result:* Dashboard loads within 3 seconds, Core Web Vitals in "Good" range

*Actual Result:* ✅ PASS - Dashboard loads in fast, all metrics good

*Validation Method:* Chrome DevTools Performance analysis + Core Web Vitals measurement
]

==== Test Case U1: Mobile Responsiveness

#colorbox(
  title: "Test Case U1: Mobile Device Usability",
  color: color-info,
)[
*Objective:* Validate optimal mobile user experience

*Test Devices:*
- iPhone (various screen sizes)
- Android phones (various screen sizes)

*Test Steps:*
1. Access application on mobile devices via mobile browsers
2. Test touch interactions and gesture support
3. Verify layout adaptation to different screen sizes
4. Test mobile-specific features (swipe, tap, long press)
5. Validate form input on mobile keyboards
6. Test audio preview playback on mobile
7. Verify navigation patterns work on touch screens
8. Check performance on mobile network connections
9. Test orientation changes (portrait/landscape)

*Expected Result:* Optimal mobile user experience with intuitive touch interactions

*Actual Result:* ✅ PASS - Responsive design works effectively across devices

*Validation Method:* Physical device testing
]

== User Acceptance Testing Documentation

=== Prototype Testing Sessions

==== Participant: Andriy D.

*Session Details:*
- Duration: 45 minutes
- Format: Supervised exploration + structured interview
- Platform: Desktop web browser

*Tasks Completed:*
1. User registration and profile setup
2. Music search and discovery
3. Rating submission (simple rating system)
4. List creation and management
5. Social features exploration

*Feedback Summary:*

#warningbox[
*Positive Feedback:*
- Appreciated vibrant color scheme and visual design
- Found website functionality intuitive and responsive
- Noted fast performance and quick page loading
- Enjoyed music discovery features

*Issues Identified:*
- Profile button in header appeared highlighted but didn't trigger navigation
- User could only access profile by clicking avatar image instead of profile button
- This created confusion about expected navigation behavior

*Resolution Implemented:*
- Fixed profile button highlighting and navigation functionality
- Ensured consistent navigation behavior across header elements
- Added hover states to clarify interactive elements
]

==== Participant: Andriy Z.

*Session Details:*
- Duration: 60 minutes  
- Format: Unmoderated exploration + detailed feedback interview
- Platform: Desktop and mobile testing

*Feedback Summary:*

#warningbox[
*Functional Suggestions:*

- When using the rating feature, suggested greater emphasis on "Complex Grading" option
- Recommended automatic redirection to complex grading section when users open this feature
- Noted that after submitting a rating, users must click "Listened" checkbox and this becomes permanent
- Suggested more flexible system allowing changes if mistakes are made
- Recommended introducing star icon rating option alongside slider interface
- Requested ability to switch between different rating input methods

*Usability Issues:*
- Platform should support better backward navigation (browser back buttons, in-app navigation)
- Navigation functionality needs thorough testing and refinement
- Complex Grading Methods icon resembled settings gear, potentially confusing users
- Recommended replacing with more representative symbol for clarity

*Design Feedback:*
- UI visually attractive and modern, made positive impression
- UX needs refinement around action clarity and navigation intuitiveness
- Overall user flow could be more streamlined

*Resolution Implemented:*
- Enhanced complex grading method prominence in rating interface
- Added star icon rating option alongside slider interface
- Improved navigation support including browser back button functionality
- Replaced complex grading icon with more intuitive representation
- Streamlined user flow for rating submission process
]

==== Participant: Andrii T.

*Session Details:*
- Duration: 40 minutes
- Format: Mobile-focused testing + feedback interview
- Platform: Mobile web browser (iOS Safari)

*Feedback Summary:*

#warningbox[
*Audio Control Feedback:*
- Music preview playback volume very loud by default
- Preferred ability to control volume directly within preview player
- Suggested volume controls to avoid discomfort and improve user experience

*UI Element Feedback:*
- Heart icon on Diary page placed near star rating system appeared misleading
- Icon looked clickable but unclear if it had interactive functionality
- Recommended moving heart icon closer to star rating for clarity
- Suggested clarifying the role of heart icon to avoid user confusion

*Feature Behavior Issues:*
- "New Releases" button redirected to search page without filtering
- Behavior didn't match user expectations for new content discovery
- Button should either show new releases directly or clarify next steps
- Recommended improving feature to meet user expectations

*Visual Design Praise:*
- Overall satisfaction with platform's color palette and UI design
- Found interface visually appealing and engaging
- Modern design approach appreciated

*Resolution Implemented:*
- Repositioned heart icons for better clarity and reduced confusion
- Improved feature behavior to match user expectations
]
