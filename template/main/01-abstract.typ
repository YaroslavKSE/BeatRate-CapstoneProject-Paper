#import "../local-lib/template-thesis.typ": *
#import "../metadata.typ": *
#pagebreak()
#heading(numbering:none)[#i18n("abstract-title", lang:option.lang)] <sec:abstract>

While the digital music landscape is rich with streaming platforms for consumption, it lacks a comprehensive space dedicated to music evaluation, critique, and meaningful social interaction around musical content. This capstone project documents the complete development of *BeatRate* - a Music Evaluation Platform that addresses this fundamental gap by providing a dedicated social space for music enthusiasts, critics, and artists to rate, review, and discover music while fostering active community engagement.

Drawing inspiration from successful platforms like Letterboxd and IMDb for movies, we identified an opportunity to create a similar ecosystem specifically tailored for the music domain. Our initial concept emerged from observing that while streaming platforms excel at music delivery, they fail to provide sophisticated tools for music evaluation and community-driven discovery. Consequently, this project aimed to develop a fully functional web application featuring: (1) a dual rating system supporting both simple (1-10) and sophisticated multi-component evaluations, (2) extensive social features enabling community interaction around musical content, (3) seamless integration with established music services through Spotify API, (4) a scalable microservices architecture capable of supporting future growth, and (5) modern cloud infrastructure deployment using AWS services.

To achieve these objectives, we conducted systematic domain research and competitor analysis to validate our concept, analyzing existing completitors to identify market gaps and opportunities. Subsequently, our development followed an agile methodology structured around three month-long sprints, implementing a microservices architecture with four core services: User Service (authentication and profiles), Music Catalog Service (Spotify integration with intelligent caching), Music Interaction Service (rating systems and reviews), and Music Lists Service (music curation features). The technical implementation utilized .NET 8 with C\# for the backend, employing Clean Architecture patterns for business services and polyglot persistence with PostgreSQL and MongoDB, while the frontend implemented a responsive React TypeScript application with modern UI/UX principles.

As a result, the project successfully delivered a production-ready platform comprising over 55,000 lines of code with comprehensive functionality across all defined requirements. Furthermore, domain research validated significant market opportunity, with existing platforms generating millions in annual revenue despite technical limitations, thereby confirming demand for improved solutions. User validation through prototype testing with 10 participants yielded positive feedback on platform functionality and visual design, with all identified usability issues resolved in subsequent development iterations. Ultimately, the implementation demonstrates successful application of modern software engineering practices, creating a compelling alternative to existing music evaluation platforms while establishing a solid foundation for future feature expansion and user adoption.

#v(2em)
#if doc.at("keywords", default:none) != none {[

  _*#i18n("keywords", lang: option.lang)*_:

  #enumerating-items(
    items: doc.keywords,
    italic: true
  )
]}
