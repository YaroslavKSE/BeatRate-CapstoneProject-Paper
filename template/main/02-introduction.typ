#import "@preview/hei-synd-thesis:0.1.1": *
#import "../metadata.typ": *
#pagebreak()
= #i18n("introduction-title", lang:option.lang) <sec:intro>

In the rapidly evolving landscape of digital music consumption, where streaming platforms have revolutionized how we discover and consume music, a critical gap exists in the space dedicated to music evaluation, critique, and meaningful social interaction around musical content. This capstone project documents the complete development of *BeatRate* - a Music Evaluation Platform designed to serve as a dedicated social space for music enthusiasts, critics, and artists to rate, review, and discover music while fostering an active community of like-minded individuals.

Unlike existing streaming platforms that prioritize consumption, BeatRate addresses the absence of a comprehensive platform that combines in-depth music evaluation with robust social features. Drawing inspiration from successful platforms like Letterboxd for films and IMDb for movies, this project represents the creation of a similar ecosystem specifically tailored for the music domain. The platform merges the elements of a social network with the depth of a sophisticated discovery and evaluation tool, enabling users to rate and review music using both traditional and innovative custom grading methods, curate personalized music lists, and engage in meaningful discussions within a diverse community.

This paper chronicles the journey of two software engineering students who, over an intensive three-month development period, transformed a conceptual solution into a fully functional web application comprising over 55,000 lines of code across multiple technologies and architectural layers. The development process encompassed detailed market research, competitor analysis, solution architecture design, and implementation of a scalable cloud-based system using modern software engineering practices.

== Project Objectives

The primary objectives of this capstone project are:

1. To develop a fully functional web application that facilitates music rating, reviewing, and discovery
2. To implement a dual rating system allowing both simple and comprehensive evaluations
3. To create robust social features enabling community interaction around musical content
4. To integrate with established music services (specifically Spotify) to access comprehensive music metadata
5. To build a scalable architecture capable of supporting growth in both users and features
6. To deploy the application using modern cloud infrastructure and DevOps practices

These objectives guided our development process throughout the project lifecycle, from initial research through implementation and deployment.

== Relevance and Significance

This project holds significance in several dimensions:

*Technical Relevance*: The development of BeatRate demonstrates the application of modern software engineering practices in creating a complex, feature-rich web application. The project showcases the implementation of microservices architecture, cloud deployment strategies, and integration with third-party APIs within a constrained timeframe.

*Market Relevance*: Our market research indicates significant growth potential in the music evaluation space, with global music streaming projected to reach US35.45 billion dollars by 2025 (Statista, 2024). The growing emphasis on personalization and community engagement in music consumption supports the need for platforms that facilitate deeper connections between listeners, critics, and artists.

*Academic Relevance*: This capstone project integrates knowledge from various courses in the Software Engineering and Business Analysis curriculum, including software architecture, database design, web development, user experience, market research, and DevOps. It demonstrates our ability to apply theoretical concepts to practical, real-world problems.

== Methodology

Our approach to developing BeatRate followed a structured methodology combining thorough research with agile development practices:

1. *Discovery Phase*: We conducted extensive research into the domain, analyzing competitor platforms, identifying market opportunities, and defining core requirements.

2. *Iterative Development*: The implementation followed three month-long development sprints, each with specific goals and deliverables:
   - Sprint 1: Core architecture and basic functionality
   - Sprint 2: Advanced features and social components
   - Sprint 3: Refinement, optimization, and deployment

3. *Technology Selection*: We carefully selected our technology stack based on project requirements, team expertise, and industry best practices. The backend uses C\# with .NET, while the frontend employs React. AWS provides our cloud infrastructure, with specific services chosen to optimize performance, scalability, and cost.

== Structure of this paper

This thesis is structured to provide both a comprehensive technical reference and an engaging narrative of the development process:

*Domain Research and Analysis* (Chapter 3) examines the current music evaluation 
platform ecosystem through competitor analysis, market research, and identification 
of gaps that justify our solution.

*System Design and Architecture* (Chapter 4) details our complete solution design, 
including software architecture decisions, technology stack selection and justification, 
economic analysis of our platform's viability, and user experience design considerations.

*Implementation Journey* (Chapter 5) chronicles the three-month development process, documenting each sprint's objectives, challenges, achievements, and retrospective insights.

*Validation and Testing* (Chapter 6) demonstrates how we verified that our implementation meets initial requirements through comprehensive testing methodologies and user validation.

*Conclusions and Future Perspectives* (Chapter 7) reflects on the project's achievements, lessons learned, and potential directions for future development.

Throughout this paper, we aim to demonstrate not only the technical implementation of BeatRate but also the thought process behind our decisions and the evolution of the project from concept to deployment. With over 55,000 lines of code and a robust feature set, BeatRate represents the culmination of our software engineering education and our passion for creating meaningful digital experiences.