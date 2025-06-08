#import "../local-lib/template-thesis.typ": *
#import "../metadata.typ": *
#pagebreak()
= Implementation <sec:impl>

The implementation of BeatRate represents the culmination of our system design, translating architectural specifications into working code across multiple microservices and a modern web frontend. This chapter documents our development methodology, architectural patterns, critical code implementations, and deployment strategies that transformed our design vision into a fully functional music evaluation platform.

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

```csharp
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

=== CQRS Implementation with Comprehensive Validation

The application layer implements Command Query Responsibility Segregation with robust validation pipelines:

```csharp
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

=== Music Catalog Service: Resilient Fallback Architecture

The Catalog Service implements sophisticated fallback strategies ensuring data availability even when external services fail:

```csharp
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

The Music Interaction Service represents our most architecturally complex component, implementing the sophisticated dual rating system that differentiates BeatRate from existing platforms. This service demonstrates advanced architectural patterns including CQRS, Domain-Driven Design, and clean architecture principles.

*Sophisticated Rating System Architecture:*

Our dual rating system represents a significant technical innovation in music evaluation platforms. The architecture enables both traditional 1-10 ratings and complex multi-component evaluations through a unified `IGradable` interface:

- *Simple Rating Flow:* Direct grade assignment with automatic normalization to 1-10 scale
- *Complex Rating Flow:* Template retrieval from MongoDB → User input application → Hierarchical calculation → PostgreSQL storage

```csharp
public class ComplexInteractionGrader
{
// Paste actual code snippets here or include other import class
}
```

*Key Technical Benefits:*
- *Unified Interface:* Both rating types implement `IGradable`, enabling polymorphic handling
- *Storage Optimization:* MongoDB for reusable templates, PostgreSQL for user-specific instances
- *Automatic Calculation:* Hierarchical grades calculate automatically when component grades change
- *Template Reusability:* Complex grading methods can be shared between users and adapted per individual

=== Music Lists Service Implementation

#infobox[
*Collaborative Implementation Note:* This section covers the Music Lists Service implementation developed by Maksym Pozdnyakov, focusing on collaborative list creation and social curation features.
]

The Music Lists Service enables comprehensive music curation and social sharing capabilities, implementing sophisticated list management with real-time collaboration features:

```csharp
public class MusicList
{
// Paste actual code snippets here or include other import class

}
```

*List Management Features:*
- *Mixed-Media Support:* Lists can contain tracks, or albums in any combination
- *Collaborative Editing:* Real-time updates with conflict resolution
- *Social Discovery:* Public/private visibility with sharing mechanisms
- *Advanced Curation:* Drag-and-drop reordering and bulk operations

=== Frontend Implementation and Architecture

The frontend application implements modern React patterns with TypeScript for type safety and maintainable component architecture:

```typescript
// State Management with Zustand
interface AuthState {
  user: UserProfile | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  fetchUserProfile: () => Promise<void>;
}

const useAuthStore = create<AuthState>((set, get) => ({
  user: null,
  isAuthenticated: AuthService.isAuthenticated(),
  isLoading: true,
  
  login: async (email: string, password: string) => {
    try {
      set({ isLoading: true, error: null });
      await AuthService.login({ email, password });
      await get().fetchUserProfile();
      set({ isAuthenticated: true, isLoading: false });
    } catch (error) {
      set({ isLoading: false, error: errorMessage });
      throw error;
    }
  }
}));
```

*Complex Grading System Frontend Implementation:*

The frontend implements sophisticated UI for the complex grading system with recursive calculation display:

```typescript
export const calculateBlockValue = (
  component: BlockComponent,
  values: Record<string, number>,
  path = ''
): BlockGradeResult => {
  const fullPath = path ? `${path}.${component.name}` : component.name;
  
  if (component.subComponents.length === 0) {
    return { name: component.name, currentGrade: 0, maxGrade: 0, minGrade: 0 };
  }

  let currentValue: number, minValue: number, maxValue: number;
  
  // Process first component
  const firstComponent = component.subComponents[0];
  if (firstComponent.componentType === 'grade') {
    currentValue = calculateGradeComponentValue(firstComponent, values, fullPath);
    minValue = firstComponent.minGrade;
    maxValue = firstComponent.maxGrade;
  } else {
    const blockResult = calculateBlockValue(firstComponent as BlockComponent, values, fullPath);
    currentValue = blockResult.currentGrade;
    minValue = blockResult.minGrade;
    maxValue = blockResult.maxGrade;
  }

  // Apply operations to subsequent components
  for (let i = 1; i < component.subComponents.length; i++) {
    const subComponent = component.subComponents[i];
    const operationCode = getOperation(component.actions[i - 1]);
    
    [currentValue, minValue, maxValue] = applyOperation(
      operationCode,
      currentValue, minValue, maxValue,
      nextCurrentValue, nextMinValue, nextMaxValue
    );
  }

  return {
    name: component.name,
    currentGrade: Number(currentValue.toFixed(2)),
    minGrade: Number(minValue.toFixed(2)),
    maxGrade: Number(maxValue.toFixed(2))
  };
};
```

*Frontend Architecture Benefits:*
- *Type Safety:* TypeScript ensures reliable API contracts and component interfaces
- *State Management:* Zustand provides lightweight, scalable state management without Redux complexity
- *Component Composition:* Modular design enables reusable UI components across different features

== Testing Approach and Quality Assurance

=== Manual Testing and User Validation

Our quality assurance approach focused on comprehensive manual testing and user feedback collection:

*Sprint-Based Testing Cycles:*
- *End-of-Sprint Testing:* Each sprint concluded with systematic manual testing of new features and regression testing of existing functionality
- *User Interviews:* Conducted both supervised and unsupervised user interviews to validate feature usability and identify pain points
- *Feature Validation:* Real-user testing sessions to verify that implemented features met the original requirements and user expectations

*Testing Coverage Areas:*
- *Authentication Flows:* Complete user registration, login, and token refresh cycles
- *Social Features:* Following, unfollowing, and social interaction functionality
- *Music Discovery:* Search, browsing, and catalog interaction workflows
- *Rating Systems:* Both simple and complex grading methodology validation
- *Cross-Browser Compatibility:* Testing across Chrome, Firefox, Safari, and Edge browsers
- *Mobile Responsiveness:* Comprehensive testing on various mobile devices and screen sizes

*Quality Metrics:*
While we did not implement automated unit test coverage, our manual testing approach identified and resolved critical issues before each sprint delivery, ensuring stable functionality for user validation sessions.

=== Performance Testing and Optimization

*Performance Monitoring Results:*
Our implementation achieved satisfactory performance characteristics without requiring extensive optimization:

*Pagination Implementation:*
- *Heavy Read Operations:* All endpoints that return large datasets implement pagination with configurable page sizes
- *Database Query Optimization:* Efficient querying strategies for user search, catalog browsing, and social feed generation
- *Response Time Metrics:* Average API response times maintained under 200ms for cached operations and under 800ms for Spotify API-dependent operations

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

```csharp
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