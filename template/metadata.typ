//-------------------------------------
// Document options
//
#let option = (
  //type : "final",
  type : "draft",
  lang : "en",
  //lang : "de",
  //lang : "fr",
  template    : "thesis"
)
//-------------------------------------
// Optional generate titlepage image
//
#import "@preview/fractusist:0.1.1":*
#let project-logo= dragon-curve(
  12,
  step-size: 10,
  stroke-style: stroke(
    paint: gradient.radial(..color.map.rocket),
    thickness: 3pt, join: "round"
  ),
  height: 5cm,
  fit: "contain",
)

//-------------------------------------
// Metadata of the document
//
#let doc= (
  title    : "Capstone Project",
  subtitle : "BeatRate Web Application Paper",
  // Primary author for document metadata
  author: (
    name        : "Yaroslav Khomych & Maksym Pozdnyakov",
    email       : "ikhomych@kse.org.ua",
    degree      : "Bachelor",
    affiliation : "KSE",
    place       : "Kyiv",
    url         : "https://github.com/YaroslavKSE",
    signature   : image("resources/img/signature.svg", width:3cm),
  ),
  // All authors for reference
  authors: (
    (
      name        : "Yaroslav Khomych",
      email       : "ikhomych@kse.org.ua",
      degree      : "Bachelor",
      affiliation : "KSE",
      place       : "Kyiv",
      url         : "https://github.com/YaroslavKSE",
      signature   : image("resources/img/signature.svg", width:3cm),
    ),
    (
      name        : "Maksym Pozdnyakov",
      email       : "mpozdnyakov@kse.org.ua",
      degree      : "Bachelor",
      affiliation : "KSE",
      place       : "Kyiv",
      url         : "https://github.com/qualia4",
      signature   : none,
    )
  ),
  keywords : ("KSE", "Software Engineering", "Thesis", "BeatRate", "Web Application"),
  version  : "v0.1.0",
)

#let summary-page = (
  logo: project-logo,
  //one sentence with max. 240 characters, with spaces.
  objective: [
    The objective of this capstone project is to
  ],
  //summary max. 1200 characters, with spaces.
  content: [
   This capstone project focuses
  ],
  address: [KSE • Kyiv School of Economics • 3 Mykoly Shpaka St • Kyiv, Ukraine \ +38 073 248 69 76 • #link("mailto"+"info@kse.ua")[info\@kse.ua] • #link("https://kse.ua")[kse.ua]]
)

#let professor= (
  affiliation: "KSE",
  name: "Isaac Newton, PhD",
  email: "inewton@kse.org.ua",
)
#let expert= (
  affiliation: "Company", 
  name: "Expert Name",
  email: "expert@domain.ua",
)
#let school= (
  name: none,
  orientation: none,
  specialisation: none,
)
#if option.lang == "de" {
  school.name = "Hochschule für Ingenieurwissenschaften Wallis, HES-SO"
  school.orientation = "Systemtechnik"
  school.specialisation = "Infotronics"
} else if option.lang == "fr" {
  school.name = "Haute École d'Ingénierie du Valais, HES-SO"
  school.shortname = "HEI-Vs"
  school.orientation = "Systèmes industriels"
  school.specialisation = "Infotronics"
} else {
  school.name = "Kyiv School of Economics"
  school.shortname = "KSE"
  school.orientation = "Software Engineering & Business Analysis"
}

#let date = (
  submission: datetime(year: 2025, month: 8, day: 14),
  mid-term-submission: datetime(year: 2025, month: 5, day: 2),
  today: datetime.today(),
)

#let logos = (
  main: project-logo,
  topleft: if option.lang == "fr" or option.lang == "de" {
    image("resources/img/logos/hei-defr.svg", width: 6cm)
  } else {
    image("resources/img/logos/kse_logo_horizontal_primary.png", width: 6cm)
  },
   topright: image("resources/img/logos/zeva.svg", width: 5cm),
)


//-------------------------------------
// Settings
//
#let tableof = (
  toc: true,
  tof: false,
  tot: false,
  tol: false,
  toe: false,
  maxdepth: 3,
)

#let gloss    = true
#let appendix = false
#let bib = (
  display : true,
  path  : "bibliography.bib",
  style : "ieee", //"apa", "chicago-author-date", "chicago-notes", "mla"
)