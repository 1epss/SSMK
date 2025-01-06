#import "@preview/bubble:0.2.2": *

#show: bubble.with(
  title: "hypoDD",
  subtitle: "A Program to Compute Double-Difference Hypocenter Locations",
  author: "Silent gyuu",
  //affiliation: "University",
  date: "Felix Waldhauser",
  //year: "Year",
  //class: "Class",
  //other: ("Made with Typst", "https://typst.com"),
  //main-color: "4DA6FF", //set the main color
  //logo: image("logo.png"), //set the logo
) 

#set page(numbering: "1", number-align: center)
#set text(font: ("Times New Roman", "Malgun Gothic"), lang: "ko", weight: "light")

#outline(depth: 2, indent: true)
#pagebreak()

#show heading: set text(font: "Times New Roman", size:13pt)
#set heading(numbering: "1.1")
#set text(size: 8pt)

#set list(marker: ([＃], [-], [-]),
          //body-indent: 1em//
          indent:0.4em)

#let zz = $arrow.r.curve$



// Edit this content to your liking

= Introduction and Overview
- Introduction and Overview
 - HypoDD는 Waldhauser와 Ellsworth (2000)의 이중 차분 알고리즘을 사용하여 진원의 위치를 재결정하는 포트란 프로그램 패키지이다. 본 문서는 그와 관련된 ph2dt 와 hypoDD 프로그램을 실행 및 사용하는 방법을 간략하게 소개한다. 이중 차분법에 대한 간략한 개요를 제공하며, ph2dt를 사용한 데이터 전처리와 hypoDD를 사용한 진원 위치의 재결정 과정을 설명한다. 부록에는 두 프로그램의 참조 매뉴얼과 보조 프로그램 및 예제 데이터에 대한 간단한 설명이 포함되어있다. 일부 보조 서브루틴들은 현재 C로 작성되어 있으며, 향후 배포에서는 C로 작성될 예정이다.
 - 진원 위치 결정 알고리즘은 보통 Geiger의 방법의 일종에 기반을 두고 있다. Geiger의 방법은 1차 테일러 급수를 이용하여 주행시간의 방정식을 선형화하는 것으로, 진원 위치에 대한 주행시간의 편미분을 통해 관측한 주행시간과 예측한 주행시간의 차이를 진원 위치를 조정하는 것과 연관짓는 방법이다. 이 알고리즘을 이용하여 진원들의 위치를 개별적으로 결정할 수도 있고, 함께 결정할 수도 있다. JHD 방법에서의 관측소 보정이나, 지진파 토모그래피에서의 지구 모델 등과 같이 다른 요소들이 각 지진의 해와 연관이 될때 진원들의 위치가 함께 결정될 수 있다. 
 -
#pagebreak()
= Features
== Colorful items

The main color can be set with the `main-color` property, which affects inline code, lists, links and important items. For example, the words highlight and important are highlighted !

- These bullet
- points
- are colored

+ It also
+ works with
+ numbered lists!

== Customized items


Figures are customized but this is settable in the template file. You can of course reference them  : @ref.

#figure(caption: [Code example],
```rust
fn main() {
  println!("Hello Typst!");
}
```
)<ref>

#pagebreak()

= Enjoy !

#lorem(100)