#import "template.typ": *
#import "fitheight.typ": *

#show: project.with(
  title: "HASH: A FORTRAN Program for Computing Earthquake First Motion Focal Mechanisms",
  authors: (
    "Silent gyuu",
  ),
  main: "image/main.png"
)

#show <r>: set text(red)

#show <b>: set text(blue)

#let zz = $arrow.r.curve$

#show raw.where(block: false): box.with(
  fill: luma(240),
  inset: (x: 3pt, y: 0pt),
  outset: (y: 3pt),
  radius: 2pt,
)

#set figure(supplement: none)

#set text(size: 9pt)
  
#set enum(spacing:1em,
          //numbering: "1)",//
          //tight: false,//
          //body-indent :,//
          full:false,
          indent:1em)
          
#set list(marker: ([＃], [-]),
          //body-indent: 1em//
          indent:0.4em)

= Introduction
- Introduction
 - 작은 지진의 단층면해는 주로 P파의 초동 극성을 이용해 결정할 수 있는데, 불완전한 속도 구조모델 등 여러 오류에 대해 매우 민감함 \ #zz 이러한 문제에 의해 개발된 것이 HASH(HArdeback & SHearer)로, 새로운 방법을 이용해 더욱 안정적인 단층면해를 계산할 수 있음 \ #zz 다양한 불확실성의 요소들로부터 적합한 결과들을 생성하고, 그 중 가장 높은 가능성을 가지는 결과를 반환함
 - 본 메뉴얼은 연구자들이 각자의 데이터셋을 이용해 HASH를 실행하는 것을 돕기 위해 작성되었으며, 소스코드는 다음의 주소#footnote[https://www.usgs.gov/node/279393 (24.12.25 기준)]를 참고
 - HASH는 격자 탐색법을 이용해 P파의 초동 극성 또는 S파와 P파의 진폭비를 기반으로 단층면해를 결정 \ #zz 각 지진에 대해 적합한 해들이 결정되면 그 분포를 통해 불확실성을 확인할 수 있고, 그에 따른 해의 품질이 결정됨 \ #zz 이때 고려되는 불확실성은 측정한 극성과 진원 위치, 출발각(속도 구조모델)으로부터 기인한 것으로, 이들 각각의 추정치가 필요함
 - HASH는 입/출력 작업을 처리하는 메인 코드와 입력값을 내부의 배열로 불러와 계산을 수행하는 서브루틴 코드로 구성 \ #zz HASH는 입력값의 형식에 의존되지 않으며, 다른 형식의 입력값을 사용한다면 메인 코드와 관측소 서브루틴 코드만 수정하면 됨
 - HASH는 SCSN(Trinet)#footnote[Southern California Seismic Network]이 수집하고 SCECE#footnote[Southern California Earthquake Data Center]이 제공한 데이터를 이용해 개발되었으며, 기존 단층면해 결정에 쓰이는 FPFIT#footnote[Reasenberg & Oppenheimer (1985). ]를 참조 \ #zz 본 메뉴얼에서 사용될 예시는 SCEDC의 지진파 위상 데이터의 표준 형식에 유사한 형식을 가짐 \ #zz HASH 1.2에 추가된 Example 4는 2008년 1월 기준 SCEDC 표준 형식을 따름   
 - HASH는 Fortran 77로 작성되었으며, Sun 워크스테이션 및 Linux, Mac OS X에서 다음과 같은 컴파일러#footnote[http://fink.sourceforge.net/]를 이용해 테스트되어짐
 - 연구에 해당 코드를 사용하셨다면, 다음의 논문을 인용해 주시기 바랍니다.
  #block(
  fill: luma(230),
  inset: 8pt,
  radius: 4pt,
  text[1. Hardebeck, Jeanne L. and Peter M. Shearer, A new method for determining first-motion focal mechanisms, Bulletin of the Seismological Society of America, 92, 2264-2276, 2002.
  2. Hardebeck, Jeanne L. and Peter M. Shearer, Using S/P Amplitude Ratios to Constrain the Focal Mechanisms of Small Earthquakes, Bulletin of the Seismological Society of America, 93, 2434-2444, 2003.])
#pagebreak()
= Overview
- Overview
 - HASH 디렉토리에는 다음과 같은 파일들이 존재해야 합니다.

#pagebreak()

= RUNNING THE CODE
== Computing Focal Mechanisms: 


== Input and Data Preparation:

== Include Files:


== Output:



#pagebreak()
= FILE FORMATS

= Input Files
== P-polarity Files: