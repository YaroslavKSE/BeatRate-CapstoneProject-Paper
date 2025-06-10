#import "../local-lib/template-thesis.typ": *
#import "../metadata.typ": *
#pagebreak()
= System Design and Architecture <sec:analysis>

== Architecture Overview and Requirements Alignment

The BeatRate platform architecture emerges directly from our functional and non-functional requirements identified in the domain research phase. Our approach prioritizes scalability, maintainability, and developer productivity while addressing the specific challenges of music evaluation and social interaction.

=== Requirements-Driven Architecture Decisions

*Functional Requirements Drive:*

- *Dual Rating System:* Our sophisticated rating architecture supports both simple (1-10) and complex multi-component grading systems through polymorphic design patterns
- *Social Features:* Microservices separation enables independent scaling of user interactions, reviews, and list management  
- *Music Integration:* Dedicated catalog service optimizes Spotify API integration with intelligent caching strategies
- *Real-time Discovery:* Service separation allows optimized data models for different query patterns

*Non-Functional Requirements Drive:*

- *Scalability:* Microservices architecture with independent scaling per service based on demand
- *Performance:* Polyglot persistence strategy matching data models to optimal storage engines
- *Maintainability:* Clear service boundaries and technology stack consistency across the platform
- *Security:* Token-based authentication with service-level validation and HTTPS encryption

== System Architecture and Major Decisions

=== Microservices Architecture Decision

*Decision:* Implement microservices architecture with four core services instead of a monolithic application.

*Justification:* Given our two-developer team constraint and the need for parallel development, microservices provide several critical advantages:

- *Parallel Development:* Yaroslav focused on User Service and Music Catalog Service while Maksym developed Music Interaction Service and Music Lists Service, enabling simultaneous feature development
- *Scalability Requirements:* Different services have distinct load patterns - catalog browsing generates different traffic than rating/review creation
- *Technology Optimization:* Each service can optimize for its specific data patterns and performance requirements
- *Code Maintainability:* With over 25,000 lines of code already implemented, a monolithic structure would create maintenance complexity that exceeds our team capacity

*Trade-offs Considered:* Increased operational complexity and potential latency from service-to-service communication, but these are outweighed by development velocity and future scalability benefits.

== System Context and External Interactions

The system context diagram illustrates BeatRate's position within the broader ecosystem of external services and user interactions. Our platform serves as the central hub connecting users with music evaluation capabilities while integrating with established services for authentication, music data, and cloud infrastructure.

#figure(
  image("../diagrams/context-diagram.png", width: 100%),
  caption: [System Context Diagram - BeatRate Platform Ecosystem],
) <fig:context-diagram>

*Key External Integrations:*

- *Spotify API:* Provides comprehensive music catalog data, track metadata, and audio previews with 200 requests per minute rate limit while the app is in development stage
- *Auth0:* Handles authentication and authorization with social login capabilities and user management
- *AWS Services:* Cloud infrastructure including S3 for avatar storage, CloudWatch for monitoring, and CloudFront for content delivery
- *MongoDB Atlas:* Cloud-hosted MongoDB service for music catalog and grading template storage

== Container Architecture and Service Decomposition

The container diagram reveals our microservices architecture with clear separation of concerns across four core services. Each service operates independently while communicating through well-defined APIs routed via Application Load Balancer.

#figure(
  image("../diagrams/container-diagram.png", width: 100%),
  caption: [Container Diagram - Microservices Architecture and Data Flow [High-resoultion version available at: https://drive.google.com/file/d/1IpK76w3QS1o2COeHDZWpZ1ZB1cufoe1r/view?usp=sharing]],
) <fig:container-diagram>

*Service Responsibilities:*

- *User Service:* Authentication, user profiles, preferences, and subscription management
- *Music Catalog Service:* Spotify API integration with intelligent caching using Redis ElastiCache
- *Music Interaction Service:* Rating systems, reviews, and complex grading calculations
- *Music Lists Service:* User-curated playlists, collections, and list management

*Data Architecture Strategy:* 

- *PostgreSQL (AWS RDS):* Transactional data requiring ACID compliance - user accounts, ratings, social interactions
- *MongoDB Atlas:* JSON-first storage for music catalog and flexible grading method templates
- *Redis ElastiCache:* High-performance caching for Spotify API responses and session data

== Technology Stack Selection and Justification

=== Backend: .NET 8 with C\#

*Decision:* Standardize on .NET 8 across all microservices.

*Justification:*

- *Team Expertise:* Both developers have extensive C\# experience, reducing learning curve and increasing development velocity
- *Performance:* .NET 8 provides excellent performance characteristics with minimal memory overhead for our API-heavy workload
- *Ecosystem:* Rich ecosystem with Entity Framework for PostgreSQL integration and robust HTTP client libraries for Spotify API integration
- *Development Experience:* Superior tooling, debugging capabilities, and IntelliSense support accelerate development

*Alternative Considered:* Node.js was evaluated but rejected due to team expertise and the superior type safety that C\# provides for our complex rating system logic.

=== Frontend: React with TypeScript

*Decision:* Implement single-page application using React with TypeScript.

*Justification:*

- *Team Experience:* Proven experience with React ecosystem reducing implementation risk
- *Component Reusability:* React's component model aligns perfectly with our UI requirements for rating widgets, music cards, and social interaction elements
- *TypeScript Benefits:* Type safety crucial for our complex grading system interfaces and API contracts
- *Community Support:* Extensive ecosystem of music-related UI components and libraries

=== Polyglot Persistence Strategy

*Decision:* Implement dual database strategy with PostgreSQL for transactional data and MongoDB for catalog data.

*PostgreSQL for User and Interaction Data:*

- *ACID Compliance:* Critical for user ratings, follows, and social interactions requiring data consistency
- *Relational Integrity:* Complex social relationships (followers, likes, comments) benefit from foreign key constraints
- *Entity Framework Integration:* Seamless C\# object mapping without custom serialization overhead
- *Complex Queries:* Efficient JOINs for social features and analytics

*MongoDB for Music Catalog Data:*

- *JSON-First Design:* Spotify API returns rich nested JSON that MongoDB stores naturally without complex ORM mapping
- *Performance:* Single read operations retrieve complete album/track data instead of multiple JOINs
- *Flexible Schema:* New Spotify fields don't require schema migrations
- *Caching Strategy:* Direct storage of Spotify API responses for rapid retrieval

*Cost Optimization Decision:* Single database instance per type rather than per-service to control costs ( \$220 month current deployment cost), with clear migration path to service-specific databases as load increases.

== Component Architecture: Music Interaction Service Deep Dive

The Music Interaction Service represents our most architecturally complex component, implementing the sophisticated dual rating system that differentiates BeatRate from existing platforms. This service demonstrates advanced architectural patterns including CQRS, Domain-Driven Design, and clean architecture principles.

#figure(
  image("../diagrams/component-diagram.png", width: 100%),
  caption: [Component Diagram - Music Interaction Service Internal Architecture [High-resoultion version available at: https://drive.google.com/file/d/1zKq4E8UJJeHFssSU1O4S15vTKT2oFJy7/view?usp=sharing]],
) <fig:component-diagram>

=== Sophisticated Rating System Architecture

Our dual rating system represents a significant technical innovation in music evaluation platforms. The architecture enables both traditional 1-10 ratings and complex multi-component evaluations through a unified `IGradable` interface:

- *Simple Rating Flow:* Direct grade assignment with automatic normalization to 1-10 scale
- *Complex Rating Flow:* Template retrieval from MongoDB → User input application → Hierarchical calculation → PostgreSQL storage

*Key Technical Benefits:*

- *Unified Interface:* Both rating types implement `IGradable`, enabling polymorphic handling
- *Storage Optimization:* MongoDB for reusable templates, PostgreSQL for user-specific instances
- *Automatic Calculation:* Hierarchical grades calculate automatically when component grades change
- *Template Reusability:* Complex grading methods can be shared between users and adapted per individual

=== Spotify API Integration Decision

*Decision:* Integrate exclusively with Spotify API rather than building our own music database or integrating multiple streaming services.

*Justification:*

- *Comprehensive API:* Spotify provides robust search, metadata, and preview capabilities with well-documented REST API
- *Rate Limits:* Free tier supports 200 requests per minute, sufficient for our initial user base with built-in rate limiting implementation
- *Real-time Updates:* Spotify's catalog stays current without requiring our own data maintenance infrastructure
- *Fallback Strategy:* We implement a hybrid approach - every Spotify fetch populates our MongoDB cache, creating automatic fallback capability for service interruptions

*Implementation Detail:*

```csharp
builder.Services.AddRateLimiter(options =>
{
    options.GlobalLimiter = PartitionedRateLimiter.Create<HttpContext, string>(_ =>
    {
        return RateLimitPartition.GetFixedWindowLimiter("global", _ =>
            new FixedWindowRateLimiterOptions
            {
                Window = TimeSpan.FromMinutes(1),
                PermitLimit = spotifySettings?.RateLimitPerMinute ?? 1000,
                QueueLimit = 100
            });
    });
});
```

== Cloud Deployment Architecture and Infrastructure

Our AWS-based infrastructure architecture provides scalable, cost-effective deployment while maintaining operational simplicity. The design leverages managed services to minimize infrastructure management overhead while ensuring high availability and performance.

#figure(
  image("../diagrams/aws-cloud-architecture.png", width: 100%),
  caption: [AWS Cloud Deployment Architecture - Production Environment [High-res version available at: https://drive.google.com/file/d/10XswGh9He38HPZo4H2Zl4HVHdzKmFdLW/view?usp=drive_link]],
) <fig:cloud-architecture>

=== Infrastructure Architecture Justification

*ECS Fargate Selection:* We chose ECS with Fargate over EKS or EC2 based on our operational requirements:

- *Low Management Overhead:* Allows focus on application features rather than infrastructure management
- *Cost Efficiency:* Pay-per-use model ideal for our growth stage with current monthly costs of \$228
- *Appropriate Scale:* Sufficient for our expected load without Kubernetes complexity
- *AWS Integration:* Native integration with ALB, CloudWatch, and other AWS services

*Load Balancing Strategy:* Path-based routing through Application Load Balancer enables:

- *Service Independence:* Each microservice receives only relevant traffic
- *Health Monitoring:* Automatic failure detection and traffic rerouting
- *SSL Termination:* Centralized HTTPS handling with CloudFront integration

=== Service Communication Patterns

Our architecture implements minimal inter-service communication to maintain loose coupling:

- *Primary Data Flow:* Frontend → ALB → Individual Services → Databases
- *Internal Communication:* Only Interaction Service → User Service for follower data retrieval

*API Versioning and Contracts:*

- *Versioning Strategy:* URL prefix pattern (`/api/v1/`) provides clear API versioning
- *Contract Stability:* Single client (our frontend) reduces versioning complexity
- *Authentication Flow:* Each service validates JWT tokens independently via Auth0 integration

== Cross-Cutting Concerns

=== Security Implementation

- *Authentication:* Auth0 provides centralized authentication with JWT token validation across all services
- *Authorization:* Service-level token validation ensures proper access control
- *Data Encryption:* HTTPS end-to-end via CloudFront, default encryption for RDS and S3 storage
- *Network Security:* VPC with public/private subnet separation isolates backend services

=== Monitoring and Observability

- *Logging:* CloudWatch integration provides centralized log aggregation across all services
- *Metrics:* ECS auto-scaling based on CPU >90% and memory >90% thresholds
- *Health Checks:* ALB performs HTTP health checks on `/health` endpoints

=== Database Migration Strategy

*Automated Migrations:* All services apply database migrations at startup with retry logic:

```csharp
context.Database.Migrate();
// Retry logic with 3 attempts and 5-second delays
```

*Zero-Downtime Deployments:* ECS rolling updates ensure continuous service availability during migrations.

== Technology Stack Summary and Trade-offs

#figure(
  table(
    columns: 4,
    stroke: 0.5pt,
    align: left,
    table.header[*Component*][*Technology*][*Justification*][*Trade-offs*],
    [Backend APIs], [.NET 8 C\#], [Team expertise, performance, ecosystem], [Learning curve for new team members],
    [Frontend], [React TypeScript], [Component reusability, type safety], [Bundle size, complexity for simple UIs],
    [User Data], [PostgreSQL], [ACID compliance, relational integrity], [Less flexible than NoSQL for schema changes],
    [Catalog Data], [MongoDB], [JSON-first, performance, flexibility], [Eventual consistency, learning curve],
    [Caching], [Redis ElastiCache], [High performance, AWS integration], [Additional complexity, memory costs],
    [Authentication], [Auth0], [Security expertise, social login], [Vendor dependency, recurring costs],
    [Music Data], [Spotify API], [Comprehensive catalog, real-time updates], [Rate limits, vendor dependency],
    [Infrastructure], [AWS ECS Fargate], [Managed scaling, AWS ecosystem], [Vendor lock-in, limited container control],
  ),
  caption: [Technology Stack Justification and Trade-off Analysis],
) <tab:tech-stack>

== Chapter Summary

This architecture successfully balances technical complexity with team capabilities, creating a scalable foundation for BeatRate's growth while maintaining development velocity and operational simplicity. The polyglot persistence strategy optimizes each data type for its specific use case, while the microservices architecture enables independent scaling and development of different platform features.

The design decisions documented in this chapter directly address the requirements identified in our domain research, providing a robust technical foundation for the implementation phase detailed in the following chapter. Each architectural choice reflects careful consideration of team constraints, technical requirements, and long-term scalability needs, resulting in a system that can grow with our user base while remaining maintainable by a small development team.