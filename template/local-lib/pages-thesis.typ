//
// Description: Custom pages for the thesis template
// Author     : Silvan Zahno
//
#import "helpers.typ": *

#let page-title-thesis(
  title: none,
  subtitle: none,
  template: "thesis",
  date: datetime.today(),
  lang: "en",
  school: (
    name: none,
    orientation: none,
    specialisation: none,
  ),
  author: (
    name        : none,
    email       : none,
    degree      : none,
    affiliation : none,
    place       : none,
    url         : none,
    signature   : none,
  ),
  professor: none,
  expert:none,
  logos: (
    topleft: none,
    topright: none,
    bottomleft: none,
    bottomright: none,
  ),
  extra-content-top: none,
  extra-content-bottom: none,
) = {

  set page(
    margin: (
      top:3.0cm,
      bottom:3.0cm,
      rest:3.5cm
    )
  )
  //-------------------------------------
  // Page content
  //
  let content-up = {
    //line(length: 100%)
    
    if extra-content-top != none {
      extra-content-top
    }

if school != none {
      //v(0.5fr)
      // Degree Programme
      align(center, [#text(size:large,
          i18n("degree-programme", lang: lang)
        )])
      align(center, [#text(size:large,
          school.orientation
        )])
        v(1em)
    }


    // BACHELOR'S THESIS / Midterm Report
    align(center, [#text(size:larger,
        [*#i18n("thesis-title", lang: lang)*]
      )])
    

    titlebox(
      title: title,
      subtitle: subtitle,
    )

    v(1em)


    align(center, [#text(size:large, [
      #if type(author) == array [
        #enumerating-authors(
          items: author,
          multiline: true,
        )
      ] else [
        #author.name
      ]
      #v(2em)
    ])])

    if extra-content-bottom != none {
      extra-content-bottom
    }
  }

  let content-down = [
    #v(2em)
    #if professor != none and (professor.affiliation != none or professor.name != none or professor.email != none ) [
      _#i18n("professor", lang: lang)_\
      #professor.affiliation#if (professor.affiliation != none and professor.name != none) or (professor.affiliation != none and professor.email != none) {[, ]}#professor.name#if professor.name != none and professor.email != none {[,]} #link("mailto:professor.email")[#professor.email]
      \ \
    ]
    #if expert != none and (expert.affiliation != none or expert.name != none or expert.email != none ) [
      _#i18n("expert", lang: lang)_\
      #expert.affiliation#if (expert.affiliation != none and expert.name != none) or (expert.affiliation != none and expert.email != none) {[, ]}#expert.name#if expert.name != none and expert.email != none {[,]} #link("mailto:expert.email")[#expert.email]
      \ \
    ]
    #if template == "thesis" [
      _#i18n("submission-date", lang: lang)_\
      #date.display("[day] [month repr:long] [year]")
    ] else if template == "midterm" [
      #i18n("submission-date", lang: lang)\
      #date.display("[day] [month repr:long] [year]")
    ]
    #v(1em)
  ]

  grid(
    columns: (50%, 50%),
    rows: (10%, 63%, 20%, 7%),
    align(left+horizon)[#logos.topleft],
    align(right+horizon)[#logos.topright],
    //stroke: 0.5pt,
    grid.cell(
      colspan: 2,
      align(horizon)[#content-up]
    ),
    grid.cell(
      colspan: 2,
      align(horizon)[#content-down]
    ),
    align(left+horizon)[#logos.bottomleft],
    align(right+horizon)[#logos.bottomright],
  )
}

#let summary(
  title: none,
  student: none,
  year: none,
  degree: none,
  field: none,
  professor: none,
  partner: none,
  logos: (
    main: none,
    topleft: none,
    bottomright: none,
  ),
  objective: none,
  address: none,
  lang: "en",
  body
) = {
  set page(
    margin: (
      top: 5.5cm,
      bottom: 3cm,
      x: 1.8cm,
    ),
    header: [
      #logos.topleft//#image(, width: 7.5cm)
    ],
    footer-descent: 0cm,
    footer: [
      #table(
        columns: (50%, 50%),
        stroke: none,
        align: (left + horizon, right + horizon),
        [
          #if address != none {
            option-style()[#address]
          } else {[
            #option-style()[HES-SO Valais Wallis • rue de l'Industrie 23 • 1950 Sion \ +41 58 606 85 11 • #link("mailto"+"info@hevs.ch")[info\@hevs.ch] • #link("www.hevs.ch")[www.hevs.ch]]
          ]}
        ],[
          #logos.bottomright
        ],
      )
    ],
  )

  set text(size: 9pt)
  set par(justify: true)

  table(
    columns: (5.4cm, 1.2cm, 1fr),
    stroke: none,
    inset: 0pt,
    [
      #if logos.main != none {
        logos.main
      } else {
        box(width: 5.4cm, height: 5cm)
      }

      #v(1cm)

      #align(center)[
        #heading(level: 3, numbering:none, outlined: false)[
          #text(15pt)[
            #i18n("thesis-title", lang: lang)\ | #h(0.3cm) #year #h(0.3cm) |
          ]
        ]
      ]

      #v(0.5cm)

      #square(size: 0.7cm, fill: blue.lighten(70%))

      #v(0.6cm)
      #set text(size: 10pt)

      #i18n("degree-programme", lang: lang)\
      _#[#degree]_

      #v(0.6cm)

      #i18n("major", lang: lang)\
      _#[#field]_

      #v(0.6cm)

      #if professor != none {[
        #i18n("professor", lang: lang)\
        _#[#professor.name]_\
        _#[#professor.email]_
        #v(0.6cm)
      ]}

      #if partner != none {[
        #i18n("partner", lang: lang)\
        _#[#partner.name]_\
        _#[#partner.affiliation]_
      ]}

    ],[],[
      #align(left, text(15pt)[
        #heading(numbering:none, outlined: false)[#title]
      ])
      #table(
        columns: (0cm, 3.5cm, 1fr),
        stroke: none,
        align: left + horizon,
        [
          //#square(size: 0.7cm, fill: blue.lighten(70%))
        ],[
          #set text(
            size: 12pt,
            fill: gray.darken(50%),
          )
          #i18n("graduate", lang: lang)
        ],[
          #set text(size: 10pt)
          #student
        ]
      )

      #v(1.5cm)

      #heading(level: 3, numbering:none, outlined: false)[
        #text(12pt)[#i18n("objective", lang: lang)]
      ]

      #if objective == none {
        [
          #i18n("objective-text")
        ]
      } else {
        objective
      }

      #v(0.6cm)

      #heading(level: 3, numbering:none, outlined: false)[
        #text(12pt)[#i18n("methods-experiences-results", lang: lang)]
      ]

      #body
    ]
  )
}

#let page-reportinfo(
  author: (),
  date: none,
  lang: "en",
) = {
  [
    #v(10em)
  ]
  heading(numbering:none, outlined: false)[#i18n("report-info", lang: lang)]
  // heading(numbering:none, outlined: false)[*#i18n("contact-info", lang: lang)*]

  // table(
  //   columns: (auto, auto),
  //   stroke: none,
  //   align: left + top,
  //   table.cell(rowspan: 3)[#if author.email != none {[#i18n("author", lang: lang):]}], [#author.name],
  //   [#author.degree #if author.degree != none {[#i18n("student", lang: lang)]}],
  //   [#author.affiliation],
  //   [#if author.email != none {[#i18n("email", lang: lang):]}], [#link("mailto:author.email")[#author.email]],
  // )

  v(3em)
  [
    //*#i18n("declaration-title", lang: lang)* \
    // #i18n("declaration-text", lang: lang)
    // - #i18n("declaration-text", lang: lang)
    // - #i18n("declaration-text", lang: lang)
    // - #i18n("declaration-text", lang: lang)
    
I, undersigned, hereby declare that this capstone project is the result of my own work.

  - All ideas, data, figures and text from other authors have been clearly cited and listed in the bibliography.
  - No part of this project has been submitted previously for academic credit in this or any other institution.
  - All code, diagrams, and third-party materials are either my original work or are used with permission and properly referenced.
  - I have not engaged in plagiarism or any form of academic dishonesty.
  - Any assistance received (e.g. from peers, tutors, or online forums) is acknowledged in the acknowledgements section.

  I understand that failure to comply with these declarations constitutes academic misconduct and may lead to disciplinary action.

  #v(5em)
]

  table(
    stroke: none,
    columns: (auto,auto),
    align: left + horizon,
    [#i18n("declaration-signature-prefix", lang: lang)], [#author.place#if author.place != none{[,]} #date.display("[day].[month].[year]")],
    [#i18n("declaration-signature", lang: lang)],
    if author.signature != none {[
      #v(0.5cm)
      //#pad(x: 2.5em, author.signature)
      #line(start: (0cm,-0cm),length:5cm)
    ]} else {[
      #line(start: (0cm,1.5cm),length:7cm)
    ]},
  )
}
