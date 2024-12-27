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
 - Source code
  #list(marker:([•]),
  [hash_driver1.f, hash_driver2.f, hash_driver3.f : 메인 코드의 예시],
  [hash_driver4.f : 새로 추가된 예시, 2008년 1월 기준 SCEDC 형식 및 5글자의 관측소 이름을 가짐],
  [hash_driver5.f : 새로 추가된 예시, 3차원 파선 트레이싱에 사용되는 SIMULPS 형식],
  [fmamp_subs.f : P파의 초동 극성과 S/P 진폭비를 이용해 단층면해를 계산하는 서브루틴],
  [fmech_subs.f : P파의 초동 극성만을 이용해 단층면해를 계산하는 서브루틴],
  [pol_subs.f : 초동 극성의 분포와 미스핏을 계산하는 서브루틴],
  [station_subs.f : 관측소의 위치와 극성의 반전 여부를 계산하는 서브루틴],
  [station_subs_5char.f : 새로 추가된 서브루틴, 5글자의 이름을 가지는 관측소 대상],
  [uncert_subs.f : 단층면해의 불확실성을 계산하는 서브루틴],
  [utils_subs.f : 기타 유틸리티를 포함한 서브루틴],
  [vel_subs.f : 속도 구조모델 테이블을 계산하는 서브루틴])
 - Include files
  #list(marker:([•]),
  [param.inc : 배열의 크기를 조절하기 위한 파라미터들],
  [hash_driver4.f : 단층면해를 결정하는데 필요한 격자의 간격 결정],
  [hash_driver5.f : 속도 구조모델 테이블 파라미터],)
 - Makefile
 - Example control files
  #list(marker: ([•]),
  [example1.inp : P파의 초동 극성만을 이용한 예시에 사용, 출발각의 불확실성을 직접 입력],
  [example2.inp : P파의 초동 극성만을 이용한 예시에 사용, 1차원 속도 구조모델들을 이용해 출발각의 불확실성을 입력],
  [example3.inp : P파의 초동 극성과 S/P 진폭비를 이용한 예시에 사용, 1차원 속도 구조모델들을 이용해 출발각의 불확실성을 입력],
  [example4.inp : 새로 추가된 예시, example2.inp와 같지만 갱신된 SCEDC의 양식을 따름],
  [example5.inp : 새로 추가된 예시, example2.inp와 같지만 SIMULPS 양식의 파일에서 방위각과 출발각을 사용])
 - Example data files
  #list(marker: ([•]),
  [north1.phase : example1에 사용되는 P파의 초동 극성 파일],
  [north2.phase : example2,3에 사용되는 P파의 초동 극성 파일],
  [north3.amp : example3에 사용되는 P파와 S파의 진폭 파일],
  [north3.statcor : example3에 사용되는 관측소별 S/P 진폭비 보정 파일],
  [north4.phase : 새로 추가된 예시, 갱신된 SCEDC 양식의 P파 초동 극성 파일],
  [north5.simul : 새로 추가된 예시, SIMULPS 로부터 계산한 방위각과 출발각 파일],
  [scsn.stations : example2,3에 사용되는 관측소 위치 파일],
  [scsn.stations_5char : example4에 사용되는 5글자의 이름을 갖는 관측소 위치 파일],
  [scsn.reverse : 모든 예시에 사용되는 관측소별 초동의 반전 기간 파일],
  [vz.socal, etc : example2,3에 사용되는 1차원 속도 구조모델]
  )
 - Example output files
  #list(marker: ([•]),
  [example1.out, example2.out, example3.out : 각 예시에 맞는 최적의 단층면해],
  [example1.out2, example2.out2, example3.out2 : 각 예시에 맞는 적합한 단층면해들],
  [example4.out, example5.out : 새로 추가된 예시, 각 예시에 맞는 최적의 단층면해],
  [example4.out2, example5.out2 : 각 예시에 맞는 적합한 단층면해들],
  )
 - 컴파일링과 프로그램의 실행은 다음과 같이 진행할 수 있음
  #block(
  fill: luma(230),
  inset: 8pt,
  radius: 4pt,
  ```bash # 컴파일링
  $ make hash_driverX                   # X = example number 
  
  # 프로그램 실행
  $ ./hash_driverX                      # 파일이 요구하는 입력값을 직접 입력
  $ ./hash_driverX < exampleX.inp       # 컨트롤 파일 이용
  ```) #zz 코드가 성공적으로 컴파일 및 실행되었다면, 생성된 출력 파일은 제공된 예시와 거의 일치할 것임 \ #zz 몬테카를로 시뮬레이션 간 입력값은 무작위로 선택되기 때문에, 난수의 생성에 차이가 발생할 경우 출력값에 차이가 발생할 수 있음 
#pagebreak()

= RUNNING THE CODE
== Computing Focal Mechanisms: 
- Computing Focal Mechanisms
 - 메인 코드는 주로 입/출력을 처리하며, 각 이벤트의 단층면해의 계산은 메인 코드에서 호출되는 세 서브루틴을 통해 수행됨 \ #zz 이 서브루틴들에 전달되는 배열에 가지고 있는 데이터의 형식을 가장 효율적으로 맞추기 위해, 메인 코드를 수정해야 함
- Computing the set of acceptable mechanisms 
 - 
- Computing the preferred, or most probable, mechanism

- Computing the data misfit for the preferred mech

== Input and Data Preparation:

== Include Files:


== Output:



#pagebreak()
= FILE FORMATS

= Input Files
== P-polarity Files: