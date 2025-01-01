#import "template.typ": *
#import "fitheight.typ": *
#import "@preview/codelst:2.0.0": sourcecode

#show: project.with(
  title: "HASH: A FORTRAN Program for Computing Earthquake First Motion Focal Mechanisms",
  subtitle: "Jeanne L. Hardeback, Peter M. Shearer",
  authors: (
    "Silent gyuu",
  ),
  main: "image/main.png")

#show <r>: set text(red)

#show <b>: set text(blue)

#let zz = $arrow.r.curve$

#set figure(supplement: none)

#set text(size: 8pt)
  
#set enum(spacing:1em,
          //numbering: "1)",//
          //tight: false,//
          //body-indent :,//
          full:false,
          indent:1em)
          
#set list(marker: ([＃], [-], [-]),
          //body-indent: 1em//
          indent:0.4em)

= Introduction
- Introduction
 - 작은 지진의 단층면해는 주로 P파의 초동 극성을 이용해 결정할 수 있는데, 불완전한 속도 구조모델 등 오차를 발생시키는 여러 원인에 대해 매우 민감한 특성을 가진다. 이러한 문제를 해결하기 위해 개발된 것이 HASH(HArdeback & SHearer)로, 새로운 방법을 이용해 더욱 안정적인 단층면해를 계산할 수 있다. HASH는 불확실성을 야기하는 다양한 요소들이 주어졌을 때, 각 지진에 대해 허용될 수 있는 단층면해들을 생성하고, 그 중 가장 높은 가능성을 가지는 결과를 출력한다. 결정된 단층면해의 정확도는 모델이 가지는 불확실성에 대해 계산된 해의 안정성 정도에 따라 결정되며, 이는 허용될 수 있는 단층면해들의 분포로 표현할 수 있다. 
 - 본 매뉴얼은 연구자들이 각자의 데이터셋을 이용해 HASH를 실행하는 것을 돕기 위해 작성되었으며, 소스코드는 다음의 주소#footnote[https://www.usgs.gov/node/279393 (24.12.25 기준)] 를 참고하라. 더 자세한 방법은 저자의 출판물에서 확인할 수 있으며, 연구에 해당 코드를 사용하였다면 다음의 논문들을 인용하길 바란다.
 #block(
  fill: luma(230),
  inset: 8pt,
  radius: 4pt,
  text[1. Hardebeck, Jeanne L. and Peter M. Shearer, A new method for determining first-motion focal mechanisms, Bulletin of the Seismological Society of America, 92, 2264-2276, 2002.
  2. Hardebeck, Jeanne L. and Peter M. Shearer, Using S/P Amplitude Ratios to Constrain the Focal Mechanisms of Small Earthquakes, Bulletin of the Seismological Society of America, 93, 2434-2444, 2003.])
 - HASH는 P파의 초동 극성(또는 S/P파의 진폭비) 기반 단층면해를 결정하기 위해 격자 탐색법을 이용하며, 그 결과 각 지진에 대해 허용될 수 있는 해들을 얻을 수 있다. 이 해들의 분포를 통해 불확실성 및 그에 동반하는 해의 정확도가 결정되어진다. 얻어진 해들은 측정한 P파의 극성과 진원의 위치, 출발각(속도 구조모델)의 불확실성을 고려하기 때문에, 따라서 이 각각의 불확실성이 어떠한 값을 가지는지에 대한 추정치가 필요하다.
 - HASH는 입/출력 작업을 처리하고, 입력 데이터를 내부의 배열로 불러오는 역할을 수행하는 메인 드라이버 코드와 단층면해, 불확실성을 계산하며 관측소의 위치와 속도 구조모델을 다루는 서브루틴 코드로 구성되어진다. HASH는 입력 데이터의 형식에 의존되지 않는 프로그램으로, 만약 다른 형식의 데이터를 사용한다면 메인 드라이버 코드와 관측소 서브루틴만 수정함으로서 간단히 작업을 수행할 수 있다. 
 - HASH는 SCSN(Southern California Seismic Network; TriNet)#footnote[Southern California Seismic Network] 이 수집하고 SCECE(Southern California Earthquake Data Center)#footnote[Southern California Earthquake Data Center] 이 제공한 데이터를 이용해 개발되었으며, 따라서 본 매뉴얼의 예시는 SCEDC 지진파 위상 데이터의 표준 배포 형식에 유사한 형식을 가진다. 또한 HASH는 기존 단층면해 결정에 널리 쓰이는 FPFIT#footnote[Reasenberg & Oppenheimer (1985). ] 를 참조하였다. HASH 1.2 버전에 추가된 Example 4는 2008년 1월 기준 SCEDC의 지진파 위상과 관측소 표준 형식을 따랐으며, 따라서 다섯 글자의 관측소명을 가지는 관측소를 포함한다.
 - HASH는 Fortran 77로 작성되었으며, 다양한 환경의 Sun 워크스테이션 및 Linux, Mac OS X에서 다음과 같은 컴파일러#footnote[http://fink.sourceforge.net/] 를 이용해 테스트되었다. 다른 환경에서 작동하기 위해 변경사항이 필요하거나, 버그를 발견한다면 저자에게 연락해주길 바란다. 
#pagebreak()
= Overview
- HASH 폴더 내에는 다음과 같은 파일들이 존재해야 한다.
 - 소스 코드 
  #block(fill: luma(230), inset: 8pt, radius: 4pt,
  list(marker:([•]),
  [hash_driver1.f, hash_driver2.f, hash_driver3.f : 메인 드라이버 프로그램],
  [hash_driver4.f : (새로 추가) 다섯 글자의 관측소명을 가지는 등 SCEDC 표준 형식을 따름],
  [hash_driver5.f : (새로 추가) 3차원 지진파 트레이싱에 사용되는 SIMULPS 형식을 따름],
  [fmamp_subs.f : P파의 초동 극성과 S/P 진폭비를 이용해 단층면해를 계산하는 서브루틴],
  [fmech_subs.f : P파의 초동 극성만을 이용해 단층면해를 계산하는 서브루틴],
  [pol_subs.f : 초동 극성의 분포와 오차를 계산하는 서브루틴],
  [station_subs.f : 관측소의 위치와 초동 극성의 반전과 관련된 서브루틴],
  [station_subs_5char.f : (새로 추가) 다섯 글자의 관측소명을 가진 관측소 위치와 초동 극성의 반전과 관련된 서브루틴],
  [uncert_subs.f : 단층면해의 불확실성을 계산하는 서브루틴],
  [utils_subs.f : 기타 유틸리티를 포함한 서브루틴],
  [vel_subs.f : 속도 구조모델 테이블에 관한 서브루틴]))
 - 설정 파일(Include files)
  #block(fill: luma(230), inset: 8pt, radius: 4pt,
  list(marker:([•]),
  [param.inc : 배열의 크기를 조절하기 위한 매개변수들 조정],
  [hash_driver4.f : 격자 검색법에 사용되는 격자의 간격 결정],
  [hash_driver5.f : 속도 구조모델 테이블 관련 매개변수 조정]))
 - Makefile
  #block(fill: luma(230), inset: 8pt, radius: 4pt,
  list(marker:([•]),
  [Makefile],))
 - 예제 컨트롤 파일
  #block(fill: luma(230), inset: 8pt, radius: 4pt,
  list(marker: ([•]),
  [example1.inp : P파의 초동 극성을 이용하여 계산할 때 사용, 출발각의 불확실성을 직접 입력],
  [example2.inp : P파의 초동 극성을 이용하여 계산할 때 사용, 1차원 속도 구조모델들을 이용해 출발각의 불확실성 입력],
  [example3.inp : P파의 초동 극성과 S/P 진폭비를 모두 이용하여 계산할 때 사용, 1차원 속도 구조모델들을 이용해 출발각의 불확실성 입력],
  [example4.inp : (새로 추가) example2.inp와 같지만 갱신된 SCEDC의 형식을 따름],
  [example5.inp : (새로 추가) example2.inp와 같지만 SIMULPS 형식의 파일으로부터 방위각과 출발각을 이용]))
 - 예제 데이터 파일
  #block(fill: luma(230), inset: 8pt, radius: 4pt,
  list(marker: ([•]),
  [north1.phase : example1에 사용되는 P파의 초동 극성 파일],
  [north2.phase : example2,3에 사용되는 P파의 초동 극성 파일],
  [north3.amp : example3에 사용되는 P파와 S파의 진폭 파일],
  [north3.statcor : example3에 사용되는 관측소별 S/P 진폭비 보정 파일],
  [north4.phase : (새로 추가) SCEDC 형식의 P파 초동 극성 파일],
  [north5.simul : (새로 추가) SIMULPS 로부터 얻은 방위각과 출발각 파일],
  [scsn.stations : example2,3에 사용되는 관측소 위치 파일],
  [scsn.stations_5char : example4에 사용되는 다섯 글자 관측소 위치 파일],
  [scsn.reverse : 모든 예시에 사용되는 관측소별 초동 극성의 반전 파일],
  [vz.socal, etc : example2,3에 사용되는 1차원 속도 구조모델 파일]))
 - 예제 출력 파일
  #block(fill: luma(230), inset: 8pt, radius: 4pt,
  list(marker: ([•]),
  [example1.out, example2.out, example3.out : 각 예제에 맞는 최적의 단층면해 출력],
  [example1.out2, example2.out2, example3.out2 : 각 예제에 맞는 허용될 수 있는 단층면해들 출력],
  [example4.out, example5.out : (새로 추가) 각 예제에 맞는 최적의 단층면해 출력],
  [example4.out2, example5.out2 : (새로 추가) 각 예제에 맞는 허용될 수 있는 단층면해들 출력]))
- 컴파일링 및 프로그램의 실행은 다음과 같이 진행할 수 있습니다.
  #block(
  fill: black,
  inset: 8pt,
  radius: 4pt,
  text([```bash # 컴파일링
  $ make hash_driverX                   # X = example number 
  
  # 프로그램 실행
  $ ./hash_driverX                      # 파일이 요구하는 입력 데이터를 직접 입력할 경우
  $ ./hash_driverX < exampleX.inp       # 컨트롤 파일을 이용하는 경우
  ```], white))
  - 코드가 성공적으로 컴파일 및 실행되었다면, 출력 파일은 제공된 예시와 거의 일치할 것이다. 출력된 결과가 샘플과 완전히 일치하지 않을 수 있는데, 이는 각 몬테카를로 시뮬레이션에 입력 데이터가 무작위로 선택되기 때문에, 난수의 생성에 차이가 발생하게 됨에 따라 차이가 발생하는 것으로 여길 수 있다.
#pagebreak()

= RUNNING THE CODE
== Computing Focal Mechanisms: 
- 단층면해 계산 
 - 메인 드라이버(프로그램)는 주로 입/출력 과정을 담당하며, 실제 지진별 단층면해의 계산은 메인 드라이버에서 호출되는 세 개의 서브루틴을 통해 수행되어진다. 메인 드라이버의 루틴들을 수정하여, 입력 데이터의 형식을 서브루틴이 받는 배열로 효율적으로 바꿔주어야 한다. 
- 허용될 수 있는 단층면해들의 계산
 - 계산 과정에 S/P 진폭비를 P파의 초동 극성과 함께 사용할 것인지 여부에 따라 별개의 유사한 서브루틴이 사용될 수 있다. 두 서브루틴 모두에 사용되는 입력 데이터로는 지진 발생 시 여러 관측소에서 측정한 P파의 초동 극성(과 S/P파 진폭비), 방위각과 출발각이 있다. 또한 이 입력 데이터들이 가지는 불확실성의 추정치는 단층면해의 안정성을 테스트하는데 필요하다.   
 - 방위각과 출발각이 가지는 불확실성은 서로 다른 진원 깊이, 속도 구조모델에 대해 수행된 반복적인 계산 과정에서 얻은 합리적인 수치들의 조합으로 나타난다. 진원 위치와 속도 구조모델을 고정해놓았다고 가정한 후 수행한 5번째 계산의 경우에서, 7번째 관측소에 대한 방위각과 출발각은 각각 #text("p_azi_mc(7,5), p_the_mc(7,5)", font:"Courier New")에 저장되며, 8번째 관측소에 대한 정보는 #text("p_azi_mc(8,5), p_the_mc(8,5)", font: "Courier New") 에 저장되어질 것이다. P파의 초동 극성과 발췌한 위상의 정확도, S/P 진폭비는 각각의 계산에서 같은 값을 가지며, 7번째 관측소에 대해 계산한 예시는 각각 #text("p_pol(7), p_qual(7), sp_amp(7)", font:"Courier New") 에 저장되어진다. 계산의 수행 횟수와 사용된 관측소의 개수는 각각 #text("nmc, npsta", font:"Courier New") 에서 정의된다. 각각의 계산 과정에서 허용 가능한 단층면해들이 생성될 것이며, 이것들을 결합하여 최종적으로 대상 지진에 대해 허용 가능한 단층면해들을 생성할 수 있다.
 - P파 초동 극성의 불확실성은 허용 가능한 초동 극성 오차의 개수를 지정함으로써 고려할 수 있으며, 출력되는 허용 가능한 단층면해들은 최대 이 개수만큼의 극성 오차를 가진 해들을 포함하는 것으로 여길 수 있다. 이때 허용된 극성 오차의 수는 최적의 단층면해가 가지는 극성 오차의 수에 추가로 #text("nextra", font:"Courier New") 가 더해진 값으로 정의된다. 만일 허용된 극성 오차의 수가 #text("ntotal", font:"Courier New") 보다 적다면, #text("ntotal", font:"Courier New") 이 허용된 극성 오차의 수로 사용될 것이다. 일반적으로, #text("ntotal", font:"Courier New") 은 초동 극성의 총 개수와 네트워크 내 알려진 극성 오차의 비율을 곱하기 때문에, 이를 바탕으로 극성 오차의 수를 예측할 수 있다. 주로 #text("ntotal", font:"Courier New")의 절반인 #text("nextra", font:"Courier New")를 사용한다. S/P 진폭비의 경우, 허용 가능한 $log_10 (S"/"P)$ 오차는 최적의 단층면해가 가지는 오차에 #text("qextra", font:"Courier New") 를 더한 값으로 정의되거나, #text("qtotal", font:"Courier New") 이 이보다 클 경우 #text("qtotal", font:"Courier New") 로 정의된다. 일반적으로 #text("qtotal", font:"Courier New") 은 S/P 진폭비의 총 개수에 평균 불확실성 추정치를 곱한 값이며, #text("qextra", font:"Courier New")는 #text("qtotal", font:"Courier New") 의 절반을 가진다.
 - #text("dang", font:"Courier New") 은 격자 검색법의 정밀도를 나타내는 매개변수이며, #text("maxout", font:"Courier New") 은 출력되는 허용 가능한 단층면해들의 최대 개수를 설정하는 매개변수이다.
 - 계산으로부터 얻어낸 허용 가능한 단층면해들의 총 개수는 #text("nf", font:"Courier New") 로 표시되며, 최대 개수는 #text("maxout", font:"Courier New") 으로 제한되어진다. 최종적으로, 각각의 허용 가능한 단층면해에 대해 단층면해에 연관된 매개변수와 두 Nodal plane의 법선 벡터가 출력된다.
 - #text("FOCALMC", font:"Courier New") 은 P파의 초동 극성만을 이용하여 단층면해를 계산하는 서브루틴이다.
  #block(fill: luma(230), inset: 8pt, radius: 4pt, [```Fortran
    subroutine FOCALMC(p_azi_mc, p_the_mc, p_pol, p_qual, npsta, nmc, dang, maxout, nextra, ntotal, nf, strike, 
                       dip, rake, faults, slips)```
  - Inputs
   #list(marker: ([•]),
  [#text("p_azi_mc(npsta, nmc)", font:"Courier New") : 방위각],
  [#text("p_the_mc(npsta, nmc)", font:"Courier New") : 출발각],
  [#text("p_pol(npsta)", font:"Courier New") : P파의 초동 극성(1 = up, -1 = down)],
  [#text("p_qual(npsta)", font:"Courier New") : P파의 초동 품질(0 = 펄스 신호, 1 = 점진적)],
  [#text("npsta", font:"Courier New") : 관측한 P파 초동의 수],
  [#text("nmc", font:"Courier New") : 각 관측소에서 가능한 방위각-출발각 조합의 수로, 계산의 횟수를 의미],
  [#text("dang", font:"Courier New") : 격자 검색법에서의 각도 간격(Degree)],
  [#text("maxout", font:"Courier New") : 출력되는 단층 면의 최대 개수로, 값을 초과할 경우 그 중 랜덤한 값이 출력],
  [#text("nextra", font:"Courier New") : 추가된 극성 오차의 수],
  [#text("ntotal", font:"Courier New") : 허용 가능한 극성 오차의 최소 개수])
  - Outputs
   #list(marker: ([•]),
   [#text("nf", font:"Courier New") : 계산된 단층면해의 수],
   [#text("strike(min(maxout, nf))", font:"Courier New") : 주향],
   [#text("dip(min(maxout, nf))", font:"Courier New") : 경사],
   [#text("rake(min(maxout, nf))", font:"Courier New") : 미끌림각],
   [#text("faults(3, min(maxout, nf))", font:"Courier New") : 단층면의 법선 벡터],
   [#text("slips(3, min(maxout, nf))", font:"Courier New") : 단층의 미끄러짐(Slip) 벡터],
   )])
 - #text("FOCALAMP_MC", font:"Courier New") 은 P파의 초동 극성과 S/P 진폭비를 모두 이용하여 단층면해를 계산하는 서브루틴이다.
  #block(fill: luma(230), inset: 8pt, radius: 4pt, [```Fortran
    subroutine FOCALAMP_MC(p_azi_mc, p_the_mc, sp_amp, p_pol, npsta, nmc, dang, maxout, nextra, ntotal, qextra, 
                           qtotal, nf, strike, dip, rake, faults, slips)
    ```
  - Inputs
   #list(marker: ([•]),
  [#text("p_azi_mc(npsta, nmc)", font:"Courier New") : 방위각],
  [#text("p_the_mc(npsta, nmc)", font:"Courier New") : 출발각],
  [#text("sp_amp(npsta)", font:"Courier New") : S/P 진폭비($log_10 ("S/P")$)],
  [#text("p_pol(npsta)", font:"Courier New") : P파의 초동 극성(1 = up, -1 = down)],
  [#text("npsta",font:"Courier New") : 관측한 P파 초동의 수],
  [#text("nmc",font:"Courier New") : 각 관측소에서 가능한 방위각-출발각 조합의 수로, 계산의 횟수를 의미],
  [#text("dang",font:"Courier New") : 격자 검색법에서의 각도 간격(Degree)],
  [#text("maxout",font:"Courier New") : 출력되는 단층 면의 최대 개수로, 값을 초과할 경우 그 중 랜덤한 값이 출력],
  [#text("nextra",font:"Courier New") : 추가된 극성 오차의 수],
  [#text("ntotal",font:"Courier New") : 허용 가능한 극성 오차의 최소 개수],
  [#text("qextra",font:"Courier New") : 추가된 진폭  오차의 최소 개수],
  [#text("qtotal",font:"Courier New") : 허용 가능한 진폭 오차의 최소 개수],
  )
  - Outputs
   #list(marker: ([•]),
   [#text("nf", font:"Courier New") : 계산된 단층면해의 수],
   [#text("strike(min(maxout, nf)", font:"Courier New")) : 주향],
   [#text("dip(min(maxout, nf)", font:"Courier New")) : 경사],
   [#text("rake(min(maxout, nf)", font:"Courier New")) : 미끌림각],
   [#text("faults(3, min(maxout, nf)", font:"Courier New")) : 단층면의 법선 벡터],
   [#text("slips(3, min(maxout, nf)", font:"Courier New")) : 단층의 미끄러짐(Slip) 벡터],
   )])
- 최적의 단층면해 계산
 - 계산으로부터 얻은 단층면해들은 최적의 단층면해 및 해의 품질 추정치를 결정하는데에 사용되며, 최적의 단층면해는 이상치들을 제거한 이후의 허용 가능한 단층면해들의 평균으로부터 얻을 수 있다. 또한 두 가지의 불확실성이 계산될 수 있는데, 허용 가능한 nodal plane과 최적의 nodal plane 사이의 RMS 차이와, 사용자가 정의한 '가까운' 각도를 기준으로 최적의 단층면해가 실제 단층면해와 '가까울' 확률로 나타낼 수 있다. 만약 이상치가 군집의 형태를 가지고 나타난다면, 이 이상치를 기반으로 단층면해의 대안을 찾을 수 있다. 사용자는 이 대안들에 대해 최소 확률을 설정할 수 있어, 낮은 확률을 가지는 해는 무시할 수 있다.
  #block(fill: luma(230), inset: 8pt, radius: 4pt,
  [```Fortran
    subroutine MECH_PROB(nf, normlin, norm2in, cangle, str_avg, dip_avg, rak_avg, prob, rms_diff)
    ```
  - Inputs
   #list(marker: ([•]),
  [#text("nf", font :"Courier New") : 단층면의 수 ],
  [#text("norm1(3,nf)" ,font :"Courier New") : 단층면의 법선 벡터],
  [#text("norm2(3,nf)",font :"Courier New") : 단층의 미끄러짐(Slip) 벡터],
  [#text("cangle",font :"Courier New") : cangle 보다 작은 각도를 가질 때, 단층면해가 실제 단층면해와 '가깝다'고 여길 수 있음],
  [#text("prob_max", font :"Courier New") : 대안 해들에 대한 최소(차단)) 확률])
  - Outputs
   #list(marker: ([•]),
  [#text("nstln", font :"Courier New") : 출력되는 해의 개수],
  [#text("str_avg(nstln)", font :"Courier New") : 각 단층면해의 주향],
  [#text("dip_avg(nstln)", font :"Courier New") : 각 단층면해의 경사],
  [#text("rak_avg(nstln)", font :"Courier New") : 각 단층면해의 미끌림각],
  [#text("prob(nstln)", font :"Courier New") : 최적의 단층면해가 실제 단층면해와 '가까울' 확률],
  [#text("rms_diff(2,nstln)", font :"Courier New") : 허용 가능한 nodal plane과 최적의 nodal plane 사이의 RMS 차이(1 = 주단층면, 2 = 보조단층면)])])
- 최적의 단층면해에 대한 데이터 오차 계산
 - 단층면해를 계산의 마지막 과정은 최적의 단층면에 대한 데이터의 오차를 찾는 것이다. 계산 과정에 S/P 진폭비를 P파의 초동 극성과 함께 사용할 것인지 여부에 따라 별개의 유사한 서브루틴이 사용될 수 있다. 입력 데이터로는 관측소 별 P파의 초동 극성(과 S/P 진폭비), 방위각, 출발각(이전 과정과 달리 최적의 조합 하나만을 사용)과 최적의 단층면해를 이용한다. 출력되는 데이터는 초동 극성의 가중 오차 #text("mfrac", font: "Courier New"), 관측소 분포비 #text("stdr", font: "Courier New") 이다. 만약 S/P 진폭비가 사용된다면, 계산된 평균 $log_10 ("S/P")$ 오차가 #text("mavg", font: "Courier New") 로 출력되어진다.
 - #text("GET_MISF", font:"Courier New") 은 P파의 초동 극성만을 이용하여 오차를 계산하는 서브루틴이다.
  #block(fill: luma(230), inset: 8pt, radius: 4pt,
  [```Fortran
    subroutine GET_MISF(npol, p_azi_mc, p_the_mc, p_pol, p_qual, str_avg, dip_avg, rak_avg, mfrac, stdr)
    ```
  - Inputs
   #list(marker: ([•]),
  [#text("npol", font:"Courier New") : 관측한 P파 초동 극성의 수],
  [#text("p_azi_mc(npol)", font:"Courier New") : 방위각],
  [#text("p_the_mc(npol)", font:"Courier New") : 출발각],
  [#text("p_pol(npol)", font:"Courier New") : P파의 초동 극성],
  [#text("p_qual(npol)", font:"Courier New") : P파의 초동 품질],
  [#text("str_avg, dip_avg, rak_avg", font:"Courier New") : 최적의 메커니즘],)
  - Outputs
   #list(marker: ([•]),
  [#text("mfrac", font:"Courier New") : 초동 극성의 가중 오차],
  [#text("stdr", font:"Courier New") : 관측소 분포비],)
   ])
 - #text("GET_MISF_AMP", font:"Courier New") 은 P파의 초동 극성과 S/P 진폭비를 모두 이용하여 오차를 계산하는 서브루틴이다.
 #block(fill: luma(230), inset: 8pt, radius: 4pt,
  [```Fortran
    subroutine GET_MISF_AMP(npol, p_azi_mc, p_the_mc, sp_ratio, p_pol, str_avg, dip_avg, rak_avg, mfrac, mavg, stdr)
    ```
  - Inputs
   #list(marker: ([•]),
  [#text("npol", font:"Courier New") : 관측한 P파 초동 극성의 개수],
  [#text("p_azi_mc(npol)", font:"Courier New") : 방위각],
  [#text("p_the_mc(npol)", font:"Courier New") : 출발각],
  [#text("sp_ratio(npol)", font:"Courier New") : S/P 진폭비],
  [#text("p_pol(npol)", font:"Courier New") : P파의 초동 극성],
  [#text("str_avg, dip_avg, rak_avg", font:"Courier New") : 최적의 메커니즘],)
  - Outputs
   #list(marker: ([•]),
  [#text("mfrac", font:"Courier New") : 초동 극성의 가중 오차],
  [#text("mavg", font:"Courier New") : 평균 $log_10 ("S/P")$ 오차],
  [#text("stdr", font:"Courier New") : 관측소 분포비],)])
#pagebreak()
== Input and Data Preparation:


#pagebreak()
== Include Files:


#pagebreak()
== Output:



#pagebreak()
= FILE FORMATS

= Input Files
== P-polarity Files: