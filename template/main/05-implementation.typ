#import "../local-lib/template-thesis.typ": *
#import "../metadata.typ": *
#import "@preview/codly:1.3.0"

#pagebreak()
= Implementation <sec:impl>

The implementation of BeatRate represents the culmination of our system design, translating architectural specifications into working code across multiple microservices and a modern web frontend. This chapter documents our development methodology, architectural patterns, critical code implementations, and deployment strategies that transformed our design vision into a fully functional music evaluation platform.

The complete source code for BeatRate is publicly available #cite(<beatrateRepository2024>), demonstrating our implementation of the architectural patterns and design decisions documented throughout this thesis.

== Development Methodology and Team Organization

=== Agile Development Approach

Our implementation followed an *Agile methodology* structured around three month-long development sprints. This approach enabled iterative development with regular feedback cycles and adaptive planning to accommodate evolving requirements and technical discoveries.

*Sprint Organization:*
- *Sprint Planning:* Each sprint began with collaborative planning sessions to define deliverables, estimate effort, and assign responsibilities based on individual expertise
- *Daily Coordination:* Regular communication through GitHub project boards and direct collaboration sessions
- *Sprint Reviews:* Each sprint concluded with demonstrations to supervisors and retrospective analysis
- *Adaptive Planning:* Requirements and priorities were adjusted based on technical feasibility and user feedback

#figure(
  image("../screenshots/github-board.png", width: 90%),
  caption: [GitHub Project Board showing completed tasks across development sprints],
) <fig:github-board>

*Team Responsibilities Distribution:*
- *Yaroslav Khomych:* User Service (authentication, profiles, social features), Music Catalog Service (Spotify integration, caching), and Frontend infrastructure setup, CI/CD pipeline setup, Deployment, and IAC (terraform).
- *Maksym Pozdnyakov:* Music Interaction Service (rating systems, reviews), Music Lists Service (curation features), and Frontend UI/UX implementation

This parallel development approach maximized our development velocity while maintaining clear ownership boundaries for different system components.

=== Iterative Design and Prototyping Strategy

Before full-scale implementation, we applied systematic prototyping strategies to validate architectural decisions and refine component interfaces:

*Service Architecture Prototyping:*
- *Clean Architecture Validation:* Created initial prototypes for User, Interaction, and Lists services to validate the four-layer separation of concerns
- *Three-Layer Architecture Testing:* Implemented simplified versions of the Catalog service to verify the streamlined approach for proxy services
- *API Contract Design:* Developed OpenAPI specifications before implementation to ensure consistent interfaces across services

*Pattern Validation:*
- *Authentication Flow Testing:* Prototyped Auth0 integration to validate token management and security patterns
- *Caching Strategy Verification:* Implemented cache-aside pattern prototypes to optimize the multi-level caching approach
- *Complex Grading System:* Created algorithmic prototypes for hierarchical grade calculations before full implementation

*Integration Testing:*
- *Spotify API Integration:* Developed test clients to validate rate limiting, error handling, and data transformation patterns
- *Database Schema Validation:* Created test migrations and seed data to verify entity relationships and query performance

This prototyping approach proved invaluable in identifying architectural adjustments early in the development process, particularly in refining the balance between Clean Architecture complexity and development velocity.

== Architectural Patterns and Coding Standards

=== Clean Architecture Implementation (User, Interaction, Lists Services)

The core business services implement *Clean Architecture* with strict layer separation and dependency inversion:

```
API Layer (Controllers, Middleware)
├── Application Layer (Commands, Queries, Handlers)
├── Domain Layer (Entities, Value Objects, Interfaces)
└── Infrastructure Layer (Repositories, External Services)
```
#figure(
  image("../diagrams/clean-architecture.png", width: 90%),
  caption: [Clean Architecture Diagram used in User, Interaction, and Lists Services],
) <fig:clean-architecture>

*Key Benefits Realized:*
- *Feature Development Velocity:* The User Service began with basic authentication and seamlessly expanded to include subscription management, user search, and avatar upload functionality without architectural refactoring
- *Testability:* Clear separation of concerns enabled isolated testing of business logic without external dependencies
- *Maintainability:* New features integrate naturally without disrupting existing functionality

=== Three-Layer Architecture (Catalog Service)

The Music Catalog Service employs a *simplified three-layer approach* optimized for its role as an intelligent Spotify proxy:

```
API Layer (Controllers, Error Handling)
├── Core Layer (Services, DTOs, Interfaces)
└── Infrastructure Layer (Repositories, Cache, External APIs)
```

*Lazy Loading Cache-Aside Pattern Implementation:*
The service implements sophisticated multi-level caching that prioritizes data availability:

1. *Redis Check:* First-level cache for immediate response
2. *MongoDB Validation:* Second-level persistent cache with expiration checking
3. *Spotify API Fetch:* Fresh data retrieval with automatic caching
4. *Graceful Degradation:* Returns stale data rather than failure when Spotify is unavailable

#figure(
  image("../diagrams/lazy-loading-pattern.png", width: 90%),
  caption: [Lazy loading pattern implementation in Catalog Serice using Redis and Mongo],
) <fig:lazy-loading-pattern>


=== Coding Standards and Conventions

*Naming Conventions:*
- *C\# Backend Services:* PascalCase for classes/methods, camelCase for private fields, 'I' prefix for interfaces
- *Frontend Components:* PascalCase for React components, camelCase for variables/functions, kebab-case for utility files
- *Database Entities:* snake_case for table/column names, consistent with PostgreSQL conventions

*Design Pattern Implementation:*
- *Factory Pattern:* API client creation with environment-specific configuration
- *Repository Pattern:* Data access abstraction with Entity Framework and MongoDB implementations
- *Command/Query Separation:* MediatR-based CQRS implementation for clear operation semantics
- *Validation Pattern:* FluentValidation with pipeline behaviors for consistent input validation

== Critical Code Implementations

=== User Service: Clean Architecture with Domain-Driven Design

The User Service demonstrates sophisticated domain modeling with encapsulated business logic and clear separation of concerns:

```cs
public class User
{
    public Guid Id { get; private set; }
    public string Email { get; private set; }
    public string Username { get; private set; }
    public string Auth0Id { get; private set; }
    public DateTime CreatedAt { get; private set; }
    public DateTime UpdatedAt { get; private set; }

    private readonly List<UserSubscription> _followers = new();
    private readonly List<UserSubscription> _following = new();

    public virtual IReadOnlyCollection<UserSubscription> Followers =>
        new ReadOnlyCollection<UserSubscription>(_followers);

    private User() { } // For EF Core

    public static User Create(string email, string username, string name, 
        string surname, string auth0Id, string avatarUrl = null, string bio = null)
    {
        return new User
        {
            Id = Guid.NewGuid(),
            Email = email,
            Username = username,
            Name = name,
            Surname = surname,
            Auth0Id = auth0Id,
            AvatarUrl = avatarUrl,
            Bio = bio,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
    }

    public void Update(string username, string name, string surname, string bio)
    {
        Username = username;
        Name = name;
        Surname = surname;
        Bio = bio;
        UpdatedAt = DateTime.UtcNow;
    }
}
```

*Domain-Driven Design Benefits:*
- *Encapsulation:* Private setters prevent unauthorized state modifications
- *Factory Pattern:* `Create` method ensures valid object construction
- *Business Logic Concentration:* Domain methods contain business rules rather than scattered across services
- *Immutable Collections:* ReadOnlyCollection prevents external manipulation of social relationships

==== Database Schema Design and Entity Relationships

The User Service implements a sophisticated relational database design that supports complex social interactions while maintaining referential integrity and query performance.

#figure(
  image("../diagrams/UserService_Data.png", width: 90%),
  caption: [User Service PostgreSQL data diagraming showing relationships between the Entities],
) <fig:lazy-loading-pattern>


*Core Database Schema:*

The database schema centers around the `users` table as the primary entity, with supporting tables for social features and user personalization:

```
users (id, email, username, name, surname, auth0_id, avatar_url, bio, created_at, updated_at)
├── user_subscriptions (follower_id, followed_id, created_at)
│   ├── UNIQUE constraint (follower_id, followed_id)
│   ├── Foreign key to users(id) as follower
│   └── Foreign key to users(id) as followed
└── user_preferences (user_id, item_type, spotify_id, created_at)
    ├── UNIQUE constraint (user_id, item_type, spotify_id)
    └── Foreign key to users(id)
```

*Social Graph Implementation:*

The user subscription system implements a many-to-many relationship through the `user_subscriptions` table, creating a bidirectional social graph:

```cs
public class UserSubscription
{
    public Guid FollowerId { get; set; }
    public Guid FollowedId { get; set; }
    public DateTime CreatedAt { get; set; }
    
    public virtual User Follower { get; set; }
    public virtual User Followed { get; set; }
}
```

This design enables efficient queries for both followers and following relationships:
- `User.Followers` → Users who follow this user (FollowedId = User.Id)
- `User.Following` → Users this user follows (FollowerId = User.Id)

*User Preferences Architecture:*

The preferences system uses a flexible design supporting multiple music item types:

```cs
public class UserPreference
{
    public Guid UserId { get; set; }
    public ItemType ItemType { get; set; } // Artist, Album, Track
    public string SpotifyId { get; set; }
    public DateTime CreatedAt { get; set; }
    
    public virtual User User { get; set; }
}
```

This enables users to maintain favorite artists, albums, and tracks with efficient querying and duplicate prevention through composite unique constraints.

==== Auth0 Integration Architecture and External Identity Management

The User Service implements sophisticated external authentication integration with Auth0 while maintaining clean architecture principles and domain integrity.

*Auth0Id as Domain Concept:*

The inclusion of `Auth0Id` in the User domain entity represents a deliberate architectural decision that balances clean architecture principles with practical authentication requirements. The Auth0Id serves as an external identity correlation mechanism, representing a valid domain concept rather than an infrastructure concern.

#figure(
  image("../screenshots/auth-user.png", width: 90%),
  caption: [Auth0 Dashboarding showing the created user with proper roles and permissions assigned],
) <fig:lazy-loading-pattern>


*Authentication Flow Implementation:*

The authentication flow demonstrates the integration between external authentication and internal domain logic:

1. *User Registration/Login* via Auth0 (Google OAuth, email/password)
2. *User Creation* in Auth0 via Management API with role assignment
3. *JWT Token Generation* containing Auth0Id and permissions
4. *Local User Creation* with Auth0Id correlation
5. *Request Authentication* through JWT validation and user resolution

*JWT Token Structure and Claims:*

When users authenticate, they receive a JWT token containing identity and authorization information:

```json
{
  "iss": "https://dev-mzz3213hmoa2myip.us.auth0.com/",
  "sub": "google-oauth2|115179652116484392346",
  "aud": ["https://api.beatrate.app/"],
  "permissions": [
    "read:profiles", "write:profiles",
    "read:reviews", "write:reviews",
    "read:interactions", "write:interactions"
  ]
}
```

*Request Authentication:*

The authentication demonstrates how external identity integrates with internal domain logic:

```cs
// Controller Authentication
var auth0UserId = User.Claims.FirstOrDefault(c => c.Type == "sub")?.Value;
var query = new GetUserProfileQuery(auth0UserId);
var userProfile = await _mediator.Send(query);

// Repository Implementation
public async Task<User> GetByAuth0IdAsync(string auth0Id)
{
    return await _context.Users
        .Include(u => u.Followers)
        .Include(u => u.Following)
        .FirstOrDefaultAsync(u => u.Auth0Id == auth0Id);
}
```

*Role and Permission Management:*

The system implements comprehensive authorization through Auth0 role management:

```cs
private async Task AssignRoleToUserAsync(string userId)
{
    var defaultRoleId = "rol_ELrBo6tr0kx7blQ9"; // User role
    var roleAssignmentRequest = new { roles = new[] { defaultRoleId } };
    
    var response = await _httpClient.PostAsJsonAsync(
        $"https://{_settings.Domain}/api/v2/users/{userId}/roles", 
        roleAssignmentRequest);
}
```

*Architectural Benefits:*

This integration approach provides several key advantages:
- *Centralized Authorization:* Permissions managed in Auth0 for consistency across services
- *Stateless Authentication:* JWT contains all necessary claims for request processing
- *Clean Architecture Compliance:* Auth0Id represents domain identity without infrastructure dependency
- *Scalable Role Management:* Easy addition and modification of permissions through Auth0
- *Cross-Service Authorization:* Other microservices validate the same JWT tokens

=== CQRS Implementation with Comprehensive Validation

The application layer implements Command Query Responsibility Segregation with robust validation pipelines:

```cs
public class RegisterUserCommandHandler : IRequestHandler<RegisterUserCommand, RegisterUserResponse>
{
    private readonly IUserRepository _userRepository;
    private readonly IAuth0Service _auth0Service;
    private readonly IValidator<RegisterUserCommand> _validator;

    public async Task<RegisterUserResponse> Handle(RegisterUserCommand command, 
        CancellationToken cancellationToken)
    {
        // Validate the command
        var validationResult = await _validator.ValidateAsync(command, cancellationToken);
        if (!validationResult.IsValid) 
            throw new ValidationException(validationResult.Errors);

        // Check for existing users
        var existingUserByEmail = await _userRepository.GetByEmailAsync(command.Email);
        if (existingUserByEmail != null) 
            throw new UserAlreadyExistsException(command.Email);

        // Create user in Auth0 and local database
        var auth0Id = await _auth0Service.CreateUserAsync(command.Email, command.Password);
        var user = User.Create(command.Email, command.Username, command.Name, 
            command.Surname, auth0Id);

        await _userRepository.AddAsync(user);
        await _userRepository.SaveChangesAsync();

        return new RegisterUserResponse
        {
            UserId = user.Id,
            Email = user.Email,
            Username = user.Username,
            CreatedAt = user.CreatedAt
        };
    }
}
```


=== Music Catalog Service: Intelligent Music Catalog Gateway

The Catalog Service implements sophisticated fallback strategies ensuring data availability even when external services fail:

```cs
public async Task<TrackDetailDto> GetTrackAsync(string spotifyId)
{
    var cacheKey = $"track:{spotifyId}";
    
    // Level 1: Try Redis cache first
    var cachedTrack = await _cacheService.GetAsync<TrackDetailDto>(cacheKey);
    if (cachedTrack != null)
    {
        _logger.LogInformation("Track {SpotifyId} retrieved from cache", spotifyId);
        return cachedTrack;
    }

    // Level 2: Try MongoDB (even if expired - better stale data than no data)
    var track = await _catalogRepository.GetTrackBySpotifyIdAsync(spotifyId);
    if (track != null)
    {
        var trackDto = TrackMapper.MapTrackEntityToDto(track);
        
        // Always cache what we have, regardless of expiration
        await _cacheService.SetAsync(cacheKey, trackDto, 
            TimeSpan.FromMinutes(_spotifySettings.CacheExpirationMinutes));

        // Return immediately if data is still valid
        if (DateTime.UtcNow < track.CacheExpiresAt)
            return trackDto;
    }

    // Level 3: Try Spotify API (with graceful fallback)
    var spotifyTrack = await _spotifyApiClient.GetTrackAsync(spotifyId);
    
    // Critical resilience: If Spotify fails and we have ANY data, use it
    if (spotifyTrack == null && track != null)
    {
        _logger.LogWarning("Spotify API unavailable for {SpotifyId}, using existing data", spotifyId);
        return TrackMapper.MapTrackEntityToDto(track);
    }

    // Process and cache fresh data from Spotify
    if (spotifyTrack != null)
    {
        var trackEntity = TrackMapper.MapToTrackEntity(spotifyTrack, track);
        trackEntity.CacheExpiresAt = DateTime.UtcNow.AddMinutes(_spotifySettings.CacheExpirationMinutes);
        
        await _catalogRepository.AddOrUpdateTrackAsync(trackEntity);
        var result = TrackMapper.MapToTrackDetailDto(spotifyTrack, trackEntity.Id);
        await _cacheService.SetAsync(cacheKey, result, 
            TimeSpan.FromMinutes(_spotifySettings.CacheExpirationMinutes));
        return result;
    }

    return null; // Complete failure - no data available anywhere
}
```

*Resilience Pattern Benefits:*
- *Always-Available Data:* Prioritizes stale data over service unavailability
- *Multi-Level Fallback:* Three-tier caching strategy minimizes external API dependency
- *Graceful Degradation:* System continues functioning even during complete Spotify outages

=== Music Interaction Service Implementation

#infobox[
*Collaborative Implementation Note:* This section details the Music Interaction Service implementation developed by Maksym Pozdnyakov, showcasing sophisticated dual rating system architecture and domain-driven design patterns.
]

The Music Interaction Service represents our most architecturally complex component, implementing the sophisticated dual rating system that differentiates BeatRate from existing platforms. This service demonstrates advanced architectural patterns including CQRS, Domain-Driven Design, and clean architecture principles while managing complex polyglot persistence requirements.

* Clean Architecture Implementation with Domain-Driven Design *

This service is structured around Clean Architecture, enforcing a strict separation between domain logic, application workflows, infrastructure, and external interfaces. The IGradable interface in the domain layer abstracts both simple and complex grading strategies, allowing polymorphic interaction handling:

```cs
// Domain Layer - Core business logic
public interface IGradable
{
    public float? getGrade();
    public float getMax();
    public float getMin();
    public float? getNormalizedGrade();
}
```

All core business rules, such as grading and review creation, are encapsulated within the InteractionsAggregate entity, which acts as the domain aggregate root:

```cs
public class InteractionsAggregate
{
    public Guid AggregateId { get; private set; }
    public string UserId { get; private set; }
    public string ItemId { get; private set; }
    public virtual Rating? Rating { get; private set; }
    public virtual Review? Review { get; private set; }
    public bool IsLiked { get; set; }

    public void AddRating(IGradable grade)
    {
        Rating = new Rating(grade, AggregateId, ItemId, CreatedAt, ItemType, UserId);
    }

    public void AddReview(string text)
    {
        Review = new Review(text, AggregateId, ItemId, CreatedAt, ItemType, UserId);
    }
}
```

The domain layer encapsulates all business rules within entity methods, ensuring that domain logic remains isolated from infrastructure concerns. The IGradable interface provides a unified abstraction for both simple grades and complex grading methods, enabling polymorphic handling throughout the system.

* Sophisticated Rating System Architecture *

Our dual rating system represents a significant innovation in music evaluation platforms. The architecture enables both traditional 1-10 ratings and complex multi-component evaluations through a unified IGradable interface:

*Simple Rating Flow:* Direct grade assignment with automatic normalization to 1-10 scale
*Complex Rating Flow:* Template retrieval from MongoDB → User input application → Hierarchical calculation → PostgreSQL storage

```cs
public class ComplexInteractionGrader
{
    public async Task<bool> ProcessComplexGrading(InteractionsAggregate interaction,
        Guid gradingMethodId, List<GradeInputDTO> gradeInputs)
    {
        // Retrieve grading method template from MongoDB
        var gradingMethod = await gradingMethodStorage.GetGradingMethodById(gradingMethodId);

        // Apply user's grades to template components
        bool allGradesApplied = ApplyGradesToGradingMethod(gradingMethod, gradeInputs);

        // Create rating with populated grading method
        interaction.AddRating(gradingMethod);

        return allGradesApplied;
    }

    private bool TryApplyGrade(IGradable gradable, List<GradeInputDTO> inputs,
        string parentPath, Dictionary<string, bool> appliedGrades)
    {
        if (gradable is Grade grade)
        {
            string componentPath = string.IsNullOrEmpty(parentPath)
                ? grade.parametrName
                : $"{parentPath}.{grade.parametrName}";

            var input = inputs.FirstOrDefault(i =>
                string.Equals(i.ComponentName, componentPath, StringComparison.OrdinalIgnoreCase));

            if (input != null)
            {
                grade.updateGrade(input.Value);
                appliedGrades[input.ComponentName] = true;
                return true;
            }
        }
        else if (gradable is GradingBlock block)
        {
            // Recursively process nested components
            string blockPath = string.IsNullOrEmpty(parentPath)
                ? block.BlockName
                : $"{parentPath}.{block.BlockName}";

            foreach (var subGradable in block.Grades)
            {
                TryApplyGrade(subGradable, inputs, blockPath, appliedGrades);
            }
        }

        return true;
    }
}
```

*Key Technical Benefits:*
- *Unified Interface:* Both rating types implement IGradable, enabling polymorphic handling
- *Storage Optimization:* MongoDB for reusable templates, PostgreSQL for user-specific instances
- *Automatic Calculation:* Hierarchical grades calculate automatically when component grades change
- *Template Reusability:* Complex grading methods can be shared between users and adapted per individual

* Database Strategy and Performance *

The service mostly uses PostgreSQL with Entity Framework Core and features strategic indexing for optimal performance. The schema is designed to handle both simple and complex rating systems while maintaining referential integrity and supporting efficient queries.

*Core Schema Design:*

The database schema centers around the Interactions table as the primary aggregate root, with one-to-one relationships to Ratings, Reviews, and Likes. This design ensures that each user interaction with a music item is tracked as a single aggregate:

```
-- Core interaction tracking
Interactions (AggregateId, UserId, ItemId, ItemType, CreatedAt)
├── Ratings (RatingId, AggregateId, IsComplexGrading)
│   ├── Grades (SimpleGrade one-to-one)
│   └── GradingMethodInstances (ComplexGrade one-to-one)
├── Reviews (ReviewId, AggregateId, ReviewText, HotScore, IsScoreDirty)
└── Likes (LikeId, AggregateId)
```

*Complex Rating Schema Architecture:*

For complex ratings, the system implements a sophisticated hierarchical structure that mirrors the MongoDB templates but stores user-specific instances in PostgreSQL:

```
GradingMethodInstances (EntityId, MethodId, Name, RatingId)
├── GradingMethodComponents (ComponentNumber, ComponentType)
│   ├── GradeComponent (for leaf nodes)
│   └── BlockComponent (for nested structures)
└── GradingMethodActions (ActionNumber, ActionType)

GradingBlocks (EntityId, Name, MinGrade, MaxGrade, Grade)
├── GradingBlockComponents (ComponentNumber, ComponentType)
└── GradingBlockActions (ActionNumber, ActionType)
```

*Performance Optimizations:*
- *Composite Indices:* (UserId, ItemId, CreatedAt) for efficient user interaction queries
- *Descending Index:* HotScore for efficient trending content retrieval
- *Unique Constraints:* Prevent duplicate interactions and ensure data integrity
- *Query Projections:* Direct DTO mapping reduces memory overhead
- *Lazy Loading Control:* Explicit Include() statements optimize query performance

*ItemStats Calculation Logic:*

The service implements a sophisticated background statistics calculation system that aggregates user interactions into comprehensive metrics for each music item:

*Real-time Stats Marking:* When users interact with music items (rate, review, or like), the system immediately marks the item as requiring statistics recalculation:

```cs
// Mark item for background processing
await _itemStatsStorage.MarkItemStatsAsRawAsync(itemId);
```

*Background Processing Service:* The ItemStatsUpdateService runs as a hosted background service, processing marked items in batches:

1. *User Interaction Aggregation:* Retrieves all interactions for an item, groups by user, and selects the most recent interaction per user to prevent duplicate counting

2. *Rating Distribution Calculation:* Analyzes normalized ratings (1-10 scale) from both simple and complex grading systems, counting occurrences in each rating bucket

3. *Social Metrics Computation:* Counts total likes and reviews from latest user interactions

4. *Average Calculation:* Computes weighted average rating across all user submissions

```cs
// Core calculation logic
var userLatestInteractions = interactions
    .GroupBy(i => i.UserId)
    .Select(g => g.OrderByDescending(i => i.CreatedAt).First())
    .ToList();

// Process both simple and complex ratings
foreach (var rating in ratings)
{
    float? normalizedValue = null;

    if (!rating.IsComplexGrading)
    {
        // Simple rating normalization
        var grade = await _dbContext.Grades.FirstOrDefaultAsync(g => g.RatingId == rating.RatingId);
        normalizedValue = grade?.NormalizedGrade;
    }
    else
    {
        // Complex rating normalization
        var complexGrade = await _dbContext.GradingMethodInstances
            .FirstOrDefaultAsync(g => g.RatingId == rating.RatingId);
        normalizedValue = complexGrade?.NormalizedGrade;
    }

    // Distribute into rating buckets (1-10)
    if (normalizedValue.HasValue)
    {
        int index = (int)Math.Round(normalizedValue.Value) - 1;
        if (index >= 0 && index < 10)
            ratingCounts[index]++;
    }
}
```

*Performance Benefits:*
- *Asynchronous Processing:* Statistics calculation doesn't impact user interaction performance
- *Dirty Flag Pattern:* Only processes items that have changed, minimizing computational overhead
- *Batch Processing:* Processes multiple items efficiently in background cycles
- *Eventual Consistency:* Provides real-time interaction feedback while maintaining accurate long-term statistics

*Social Features and Hot Score System*

The service integrates a trending content mechanism using a custom "Hot Score" algorithm, which weights engagement by recency and type of interaction:

```cs
public class ReviewHotScoreCalculator
{
    private readonly float _likeWeight = 1.0f;
    private readonly float _commentWeight = 2.0f;
    private readonly float _timeConstant = 2.0f;
    private readonly float _gravity = 1.5f;

    public float CalculateHotScore(int likes, int comments, DateTime createdAt)
    {
        double ageDays = Math.Min((DateTime.UtcNow - createdAt).TotalDays, 30);
        float rawScore = (_likeWeight * likes) + (_commentWeight * comments);
        double denominator = Math.Pow(ageDays + _timeConstant, _gravity);
        return (float)(rawScore / denominator);
    }
}
```

*Features include:*
- Time-based decay (score fades over 30 days)
- Weighted engagement (comments > likes)
- Background recalculations via a hosted service
- Optimized recalculation using a dirty-flag pattern

* Like and Comment System *

For features such as likes, the service ensures integrity with validation, idempotency checks, and hot score recalculations:

```cs
public async Task<ReviewLike> AddReviewLike(Guid reviewId, string userId)
{
    // Check if the review exists
    var reviewExists = await _dbContext.Reviews.AnyAsync(r => r.ReviewId == reviewId);
    if (!reviewExists)
        throw new KeyNotFoundException($"Review with ID {reviewId} not found");

    // Prevent duplicate likes
    var existingLike = await _dbContext.ReviewLikes
        .FirstOrDefaultAsync(l => l.ReviewId == reviewId && l.UserId == userId);
    if (existingLike != null)
        return ReviewLikeMapper.ToDomain(existingLike);

    // Create new like and mark review for hot score recalculation
    var reviewLike = new ReviewLike(reviewId, userId);
    var reviewLikeEntity = ReviewLikeMapper.ToEntity(reviewLike);

    // Mark review as dirty for hot score recalculation
    var review = await _dbContext.Reviews.FindAsync(reviewId);
    review.IsScoreDirty = true;

    await _dbContext.ReviewLikes.AddAsync(reviewLikeEntity);
    await _dbContext.SaveChangesAsync();

    return reviewLike;
}
```

Other performance practices include:
- Lazy loading control via Include()
- Query projections to DTOs for memory efficiency
- Pagination with total count optimization

=== Music Lists Service Implementation

#infobox[
*Collaborative Implementation Note:* Also developed by Maksym Pozdnyakov, this service enables collaborative music curation with social interactions. It reuses patterns from the Music Interaction Service while focusing on dynamic list creation.
]

The Music Lists Service enables comprehensive music curation and social sharing capabilities, implementing sophisticated list management with real-time collaboration features and leveraging the same social interaction patterns established in the Music Interaction Service.

* Domain Model and Business Logic *

At its core, the List entity encapsulates the list type, metadata, ranking logic, and a collection of items:

```cs
public class List
{
    public Guid ListId { get; set; }
    public string UserId { get; set; }
    public string ListType { get; set; }
    public DateTime CreatedAt { get; set; }
    public string ListName { get; set; }
    public string ListDescription { get; set; }
    public bool IsRanked { get; set; }
    public List<ListItem> Items { get; set; }
    public int Likes { get; set; }
    public int Comments { get; set; }

    public List(string userId, string listType, string listName,
        string listDescription, bool isRanked)
    {
        ListId = Guid.NewGuid();
        UserId = userId;
        ListType = listType;
        ListName = listName;
        ListDescription = listDescription;
        IsRanked = isRanked;
        CreatedAt = DateTime.UtcNow;
        Items = new List<ListItem>();
    }
}
```

* Database Strategy and Performance *

The Music Lists Service employs a clean relational design optimized for efficient list management and discovery. The schema separates list metadata from list items, enabling optimal query performance for different access patterns.

*Core Schema Design:*

```
Lists (ListId, UserId, ListType, ListName, ListDescription, IsRanked, HotScore, IsScoreDirty, CreatedAt)
├── ListItems (ListItemId, ListId, ItemId, Number)
├── ListLikes (LikeId, ListId, UserId, LikedAt)
└── ListComments (CommentId, ListId, UserId, CommentedAt, CommentText)
```

*Key Performance Optimizations:*
- *Separate Item Storage:* ListItems table allows efficient querying of all lists containing a specific music item
- *HotScore Indexing:* Descending index on HotScore enables fast retrieval of trending lists
- *Composite Indexes:* (ListId, UserId) unique constraint prevents duplicate likes while optimizing social query performance
- *Type-Based Filtering:* ListType index supports efficient filtering by list categories (albums, tracks, mixed)

This design allows the system to efficiently answer queries like "show me all lists containing this track, ordered by popularity" by leveraging the ListItems.ItemId index combined with Lists.HotScore ordering, typically completing in under 50ms even with thousands of lists.

* Advanced List Management Features *

The system supports ranked and unranked lists with dynamic item placement and shifting logic:

```cs
public async Task<int> InsertListItemAsync(Guid listId, string spotifyId, int? position)
{
    using var transaction = await _dbContext.Database.BeginTransactionAsync();
    try
    {
        // Prevent duplicate items
        bool alreadyExists = await _dbContext.ListItems
            .AnyAsync(i => i.ListId == listId && i.ItemId == spotifyId);
        if (alreadyExists)
            throw new InvalidOperationException("Item already exists in list.");

        // Calculate optimal insertion position
        var existingItems = await _dbContext.ListItems
            .Where(i => i.ListId == listId)
            .ToListAsync();

        int actualPosition = position ?? (existingItems.Any() ?
            existingItems.Max(i => i.Number) + 1 : 1);

        // Shift existing items to accommodate insertion
        var itemsToShift = existingItems
            .Where(i => i.Number >= actualPosition)
            .OrderByDescending(i => i.Number)
            .ToList();

        foreach (var item in itemsToShift)
            item.Number += 1;

        // Create and insert new item
        var newItem = new ListItemEntity
        {
            ListItemId = Guid.NewGuid(),
            ListId = listId,
            ItemId = spotifyId,
            Number = actualPosition
        };

        await _dbContext.ListItems.AddAsync(newItem);
        await _dbContext.SaveChangesAsync();
        await transaction.CommitAsync();

        return actualPosition;
    }
    catch (Exception)
    {
        await transaction.RollbackAsync();
        throw;
    }
}
```

This approach supports flexible user control while ensuring consistency in ranked lists

* Social Features Integration *

The Music Lists Service leverages the same social interaction infrastructure established in the Music Interaction Service:

*Like System:* Implements identical like/unlike functionality as the Music Interaction Service, with the same duplicate prevention logic and database constraints.

*Comment System:* Utilizes the same comment architecture as reviews in the Music Interaction Service, enabling discussions on music lists.

*Hot Score Algorithm:* Employs the same hot score calculation system as the Music Interaction Service to promote trending lists based on user engagement, using identical weighting and time-decay algorithms.

* Advanced Query Implementation *

The service implements sophisticated pagination and search strategies:

```cs
public async Task<PaginatedResult<ListWithItemCount>> GetListsByUserIdAsync(
    string userId, int? limit = null, int? offset = null, string? listType = null)
{
    // Efficient query construction with selective loading
    IQueryable<ListEntity> query = _dbContext.Lists
        .Where(l => l.UserId == userId);

    if (!string.IsNullOrWhiteSpace(listType))
        query = query.Where(l => l.ListType == listType);

    // Get total count before pagination
    int totalCount = await query.CountAsync();

    // Apply pagination with preview items optimization
    var listEntities = await query
        .Skip(offset ?? 0)
        .Take(limit ?? 20)
        .Include(l => l.Likes)
        .Include(l => l.Comments)
        .ToListAsync();

    // Load preview items separately for efficiency
    foreach (var listEntity in listEntities)
    {
        var previewItems = await _dbContext.ListItems
            .Where(i => i.ListId == listEntity.ListId)
            .OrderBy(i => i.Number)
            .Take(5)
            .ToListAsync();
    }

    return new PaginatedResult<ListWithItemCount>(mappedLists, totalCount);
}
```

=== Frontend Implementation and Architecture

*Overall Description*

The frontend application implements a modern, responsive music rating and review platform built with React and TypeScript, providing a comprehensive user experience across both desktop and mobile devices. The application leverages contemporary web technologies to deliver an intuitive interface for music discovery, rating, and social interaction.

*Technology Stack:*
- *React with TypeScript:* Single-page application implementation utilizing React's component-based architecture with TypeScript for enhanced type safety and developer experience
- *Tailwind CSS:* Utility-first CSS framework for consistent, responsive styling and rapid UI development
- *Lucide React:* Modern icon library providing clean, scalable SVG icons throughout the interface
- *Color Scheme:* Primary brand color HEX \#7a24ec (purple) creating a distinctive visual identity across all interface elements

The frontend communicates with the backend microservices through RESTful APIs, implementing proper authentication flows and state management to ensure seamless user interactions.

*Additional Features*

*Mobile-First Responsive Design:* The application prioritizes mobile usability with dedicated responsive layouts for all components. Mobile-specific interface adaptations include:
- Condensed navigation patterns optimized for touch interaction
- Simplified layouts that prioritize content hierarchy on smaller screens
- Touch-friendly button sizing and spacing throughout the interface
- Adaptive grid systems that gracefully scale from mobile to desktop viewports

*Dynamic Content Loading:* Advanced pagination and infinite scroll implementation provides smooth content discovery:
- *Review Loading:* As users scroll through their diary entries, additional reviews load dynamically without page refreshes, maintaining browsing context
- *Intelligent Prefetching:* The system preloads preview information for music items in batches, reducing perceived loading times
- *Optimized Query Strategies:* Database queries implement efficient pagination with configurable page sizes (typically 20 items per load) to balance performance and user experience

*Platform Pages and Interface Design*

*Home Page:* Central landing page featuring personalized content discovery, new music releases carousel, quick search functionality, and activity feed for followed users. Includes animated feature cards highlighting key platform capabilities.

*Profile Page:* Comprehensive user profile interface with tabbed navigation including overview statistics, grading methods, music preferences, rating history, social connections (followers/following), and personal settings management.

#figure(
  grid(
    columns: (30%, 70%),
    column-gutter: 1em,
    image("../screenshots/profile-mobile.png", width: 85%, fit: "stretch"),
    image("../screenshots/profile-desktop.png", width: 100%)
  ),
  caption: [Profile Page interface - Mobile (left) displaying condensed header and vertical tab navigation with touch-optimized interface elements, Desktop (right) showing tabbed interface with user statistics, grading methods, and social connections in a wide layout optimized for desktop viewing],
) <fig:profile-pages>

*Diary Page:* Personal music journal displaying chronologically organized user interactions including ratings, reviews, and all listened tracks. Features dynamic loading as user scrolls through the page.

#figure(
  grid(
    columns: (30%, 70%),
    column-gutter: 1em,
    image("../screenshots/diary-mobile.png", width: 85%, fit: "stretch"),
    image("../screenshots/diary-desktop.png", width: 100%)
  ),
  caption: [Diary Page interface - Mobile (left) showing vertical timeline layout optimized for touch navigation, Desktop (right) displaying wider content layout with enhanced readability],
) <fig:diary-pages>

*Grading Method Pages:* Interface for creating, viewing, and managing custom rating systems with multi-component criteria, weighting systems and other features.

#figure(
  image("../screenshots/graiding-method-page.png", width: 80%),
  caption: [Graiding methods],
) <fig:interaction-mobile>


*Lists Pages:* Music list management interface for creating, editing, and organizing custom collections of tracks and albums. Supports both ranked and unranked lists with drag-and-drop reordering functionality.

#figure(
  grid(
    columns: (30%, 70%),
    column-gutter: 1em,
    image("../screenshots/lists-mobile.png", width: 85%, fit: "stretch"),
    image("../screenshots/lists-desktop.png", width: 100%)
  ),
  caption: [Lists Page interface - Mobile (left) featuring vertical list layout and touch-optimized list management, Desktop (right) displaying grid layout with enhanced preview and creation tools],
) <fig:lists-pages>

*Item Page:* Detailed view for individual tracks or albums displaying comprehensive metadata, user ratings distribution, related reviews, and social interaction features including likes and comments. Provides possibility to listen to 30-second song previews from tracklist tab on Album page or header on Song page.

#figure(
  grid(
    columns: (30%, 70%),
    column-gutter: 1em,
    image("../screenshots/item-page-mobile.png", width: 85%, fit: "stretch"),
    image("../screenshots/item-page-desktop.png", width: 100%)
  ),
  caption: [Item Page interface - Mobile (left) with condensed vertical layout and touch-friendly controls, Desktop (right) showing expanded metadata and tabbed content organization],
) <fig:item-pages>

*Interaction Page:* Detailed view of specific user interactions (ratings/reviews) with full review text, complex rating breakdowns, social engagement metrics, and contextual information about the rated music item.

#figure(
  grid(
    columns: (30%, 70%),
    column-gutter: 1em,
    image("../screenshots/interaction-mobile.png", width: 85%, fit: "stretch"),
    image("../screenshots/interaction-desktop.png", width: 100%)
  ),
  caption: [Interaction Page interface - Mobile (left) with vertical content flow and mobile-friendly social interaction buttons, Desktop (right) showing side-by-side layout for review content and music item information],
) <fig:interaction-pages>


*Search Page:* Advanced music discovery interface with real-time search across tracks, albums, and artists. Integrates Spotify catalog data with filtering options across different categories.



*People Page:* User discovery and social networking interface for finding other users, viewing profiles, managing follow relationships, and browsing community activity.

== Deployment and Configuration Management

=== Containerization and CI/CD Pipeline

The deployment strategy leverages comprehensive containerization and automated CI/CD pipelines built with GitHub Actions:

```yaml
name: Build and Deploy Services
on:
  push:
    branches: [main, development]
  pull_request:
    branches: [main]

jobs:
  detect-changes:
    runs-on: ubuntu-latest
    outputs:
      user-service: ${{ steps.changes.outputs.user-service }}
      catalog-service: ${{ steps.changes.outputs.catalog-service }}
      # Additional service detection...
    
  build-user-service:
    needs: detect-changes
    if: needs.detect-changes.outputs.user-service == 'true'
    runs-on: ubuntu-latest
    steps:
      - name: Build and Push Docker Image
        run: |
          docker build -t ghcr.io/beatrate/user-service:${{ github.sha }} .
          docker push ghcr.io/beatrate/user-service:${{ github.sha }}
      
      - name: SonarCloud Analysis
        uses: SonarSource/sonarcloud-github-action@master
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

#figure(
  image("../screenshots/github-actions.png", width: 90%),
  caption: [GitHub Actions CI/CD pipeline with automated testing and deployment],
) <fig:github-actions>

*CI/CD Pipeline Features:*
- *Path-Based Triggering:* Only modified services are built and deployed, optimizing build times
- *Semantic Versioning:* Automated version management with configurable increment strategies
- *Code Quality Integration:* SonarCloud analysis ensures code quality standards across all services
- *Container Registry:* Automated publishing to GitHub Container Registry (GHCR) with proper tagging
- *Environment-Specific Deployment:* Separate pipelines for development and production environments

#figure(
  image("../screenshots/sonarcloud.png", width: 90%),
  caption: [SonarCloud integration showing code quality metrics and analysis],
) <fig:sonarcloud>

*Deployment Architecture:*
- *Development Environment:* Automated deployment to EC2 instances using AWS Systems Manager (SSM) for remote execution
- *Docker Compose Orchestration:* Service-specific updates and full system deployment capabilities
- *Infrastructure as Code:* Terraform configurations prepared for production environment automation

=== Configuration Management Strategy

*Environment-Specific Configuration:*
- *Development:* Local development with Docker Compose for service dependencies
- *Staging:* EC2-based deployment environment mirroring production architecture
- *Production:* Designed with ECS Fargate for scalable, managed container orchestration

*Secret Management:*
- *Development:* Local environment variables and development-specific credentials
- *Production:* AWS SSM Parameter store integration for secure credential management
- *CI/CD:* GitHub Secrets for deployment credentials and API keys

== Documentation and Maintainability

=== API Documentation and Standards

*Swagger/OpenAPI Integration:*
All microservices implement comprehensive API documentation using Swagger/OpenAPI specifications:

```cs
// Program.cs - Swagger Configuration
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo 
    { 
        Title = "User Service API", 
        Version = "v1",
        Description = "User management and authentication service"
    });
    
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT"
    });
});
```

*Documentation Deliverables:*
- *README Guidelines:* Each service includes comprehensive setup and development instructions
- *API References:* Interactive Swagger documentation for all endpoints
- *Architecture Decision Records:* Key architectural decisions documented with rationale and trade-offs
- *Deployment Guides:* Step-by-step instructions for local development and production deployment

=== Code Documentation Standards

*Inline Documentation:*
- *XML Documentation:* All public APIs include comprehensive XML documentation comments
- *Code Comments:* Complex algorithms and business logic include explanatory comments
- *Configuration Documentation:* All configuration options documented with examples and valid ranges

== Chapter Summary

The implementation phase successfully translated our architectural designs into a fully functional music evaluation platform comprising over 55,000 lines of code across multiple services and technologies. The combination of Clean Architecture for business services and streamlined three-layer architecture for proxy services proved optimal for our team size and project requirements.

Key implementation achievements include:

- *Robust Authentication System:* Complete user management with Auth0 integration and secure token handling
- *Intelligent Music Catalog:* Resilient Spotify integration with multi-level caching and graceful degradation
- *Sophisticated Rating Systems:* Dual rating methodology supporting both simple and complex evaluations with hierarchical calculations
- *Modern Frontend:* Responsive, type-safe React application with efficient state management
- *Production-Ready Deployment:* Comprehensive CI/CD pipeline with automated testing and quality assurance

The iterative development approach and clear architectural patterns enabled rapid feature development while maintaining code quality and system reliability. The implementation serves as a solid foundation for future platform growth and feature expansion, demonstrating the successful application of modern software engineering practices to create a compelling user experience in the music evaluation domain.