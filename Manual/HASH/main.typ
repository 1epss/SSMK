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
  $ ./hash_driverX                      # 파일이 요구하는 입력값을 직접 입력할 경우
  $ ./hash_driverX < exampleX.inp       # 컨트롤 파일을 이용하는 경우
  ```], white))
  - 코드가 성공적으로 컴파일 및 실행되었다면, 출력 파일은 제공된 예시와 거의 일치할 것이다. 출력된 결과가 샘플과 완전히 일치하지 않을 수 있는데, 이는 각 몬테카를로 시뮬레이션에 입력 데이터가 무작위로 선택되기 때문에, 난수의 생성에 차이가 발생하게 됨에 따라 차이가 발생하는 것으로 여길 수 있다.
#pagebreak()

= RUNNING THE CODE
== Computing Focal Mechanisms: 
- Computing Focal Mechanisms
 - 메인 코드는 주로 입/출력을 처리하며, 각 이벤트의 단층면해의 계산은 메인 코드에서 호출되는 세 서브루틴을 통해 수행됨 \ #zz 이 서브루틴들에 전달되는 배열에 가지고 있는 데이터의 형식을 가장 효율적으로 맞추기 위해, 메인 코드를 수정해야 함
- Computing the set of acceptable mechanisms 
 - S/P 진폭비를 P파의 초동 극성과 함께 사용할 것인지 여부에 따라 별개의 유사한 서브루틴이 사용됨 \ #zz 양쪽의 서브루틴에는 관측소들의 P파 초동 극성, S/P파 진폭비, 방위각과 출발각이 입력값으로 들어감 \ #zz 입력값들의 불확실성 추정치 또한 단층면해의 안정성을 테스트하는데 필요함   
 - 방위각과 출발각의 불확실성은 서로 다른 진원 깊이, 속도 구조모델에 대해 반복적인 계산 시도에서 얻은 합리적인 수치들로 나타남 \ #zz 예를 들어 5번째 시도의 경우, 진원 위치와 속도 구조모델은 고정되어 있고, 7번째 관측소에 대한 방위각과 출발각은 각각 `p_azi_mc(7,5)`, `p_the_mc(7.5)` 에 저장되며, 8번째 관측소는 `p_azi_mc(8,5)`, `p_the_mc(8,5)` 에 저장됨 \ #zz 초동의 극성과 발췌 정확도, S/P 진폭비는 각각의 시도에서 같은 값을 가지며, 7번째 관측소에 대해 각각 `p_pol(7)`, `p_qual(7)`, `sp_amp(7)` 에 저장되게 됨 \ #zz 시도 횟수와 관측소의 개수는 각각 `nmc`, `npsta`에서 정의 \ #zz 각각의 시도 간에 적합한 단층면해들이 만들어질 것이며, 그것들을 결합하여 대상 지진에 대해 적합한 단층면해들을 생성
 - P파의 초동 피크의 불확실성은 얼마나 많은 극성 오차가 허용 가능한지에 따라 설명될 수 있음 \ #zz 결과값으로 나온 적합한 단층면해들은 이러한 미스핏 극성들을 포함한 해로 여길 수 있음 \ #zz 허용된 미스핏 극성의 수는 최적의 해가 가지는 미스핏 극성의 수에 추가로 `nextra` 를 더한 값으로 정의됨 \ #zz 만약 이 허용된 미스핏 극성의 수가 `ntotal`보다 적다면, `ntotal`이 허용된 미스핏의 수로 사용됨 \ #zz 일반적으로 `ntotal` 값은 극성의 총 개수와 네트워크의 알려진 극성 오차의 비율을 곱한 값을 이용해, 극성 미스핏 수를 예상할 수 있음 \ #zz 주로 `ntotal`의 절반인 `nextra`를 사용함 \ #zz 또한, S/P 진폭비의 경우 허용가능한 $log_10 (S"/"P)$ 미스핏은 최적의 해의 미스핏에 `qextra`를 더한 값으로 정의하며, 이게 `qtotal`보다 작으면 `qtotal`을 사용 \ #zz 일반적으로 `qtotal`은 S/P 진폭비의 총 개수에 평균 불확실성 추정치를 곱한 값이며, `qextra`는 `qtotal`의 절반
 - `dang` 은 격자 검색의 정밀도를 나타내는 파라미터이며, `maxout`은 적합한 단층면해들의 최대 개수를 설정하는 파라미터
 - 찾아낸 적합한 단층면해의 총 개수는 `nf`로 표시되지만, 최대 개수는 `maxout`으로 제한됨 \ #zz 각각의 적합한 단층면해에 대해, 단층면해에 관련된 파라미터와 두 Nodal plane의 법선 벡터가 반환됨
 - P파의 초동 극성만 이용할 경우 `FOCALMC` 서브루틴을 이용하며, 다음과 같은 입/출력값을 가짐 \ 
  #sourcecode[
    ```Fortran
    subroutine FOCALMC(p_azi_mc, p_the_mc, p_pol, p_qual, npsta, nmc, dang, maxout, nextra,
    ntotal, nf, strike, dip, rake, faults, slips)
    ```]
  - Inputs
   #list(marker: ([•]),
  [p_azi_mc(npsta, nmc) : 방위각],
  [p_the_mc(npsta, nmc) : 출발각],
  [p_pol(npsta) : 초동 극성(1 = up, -1 = down)],
  [p_qual(npsta) : 초동 quality(0 = 펄스, 1 = 점진적)],
  [npsta : 관측한 초동의 수],
  [nmc : 시도 횟수(주어진 각 관측소에서의 방위각-출발각 쌍의 수)],
  [dang : 격자 검색에서의 각도 간격(Degree)],
  [maxout : 반환되는 단층 면의 최대 개수(만약 더 발견된다면, 랜덤한 값이 리턴)],
  [nextra : 허용되는 추가 미스핏의 수],
  [ntotal : 허용되는 총 미스핏의 최소 개수],
  )
  - Outputs
   #list(marker: ([•]),
   [nf : 찾아낸 단층면해의 수],
   [strike(min(maxout, nf)) : 주향],
   [dip(min(maxout, nf)) : 경사],
   [rake(min(maxout, nf)) : 미끌림각],
   [faults(3, min(maxout, nf)) : 단층의 법선 벡터],
   [slips(3, min(maxout, nf)) : Slip 벡터],
   )
 - P파의 초동 극성과 S/P 진폭비를 모두 이용할 경우 `FOCALAMP_MC` 서브루틴을 이용
  #sourcecode[
    ```Fortran
    subroutine FOCALAMP_MC(p_azi_mc, p_the_mc, sp_amp, p_pol, npsta, nmc, dang, maxout, nextra,
    ntotal, qextra, qtotal, nf, strike, dip, rake, faults, slips)
    ```]
  - Inputs
   #list(marker: ([•]),
  [#text("p_azi_mc(npsta, nmc)", font:"Courier New") : 방위각],
  [#text("p_the_mc(npsta, nmc)", font:"Courier New") : 출발각],
  [#text("sp_amp(npsta)", font:"Courier New") : 진폭비($log_10 ("S/P")$)],
  [#text("p_pol(npsta)", font:"Courier New") : 초동 극성(1 = up, -1 = down)],
  [#text("npsta",font:"Courier New") : 관측한 초동의 수],
  [#text("nmc",font:"Courier New") : 시도 횟수(주어진 각 관측소에서의 방위각-출발각 쌍의 수)],
  [#text("dang",font:"Courier New") : 격자 검색에서의 각도 간격(Degree)],
  [#text("maxout",font:"Courier New") : 반환되는 단층 면의 최대 개수(만약 더 발견된다면, 랜덤한 값이 리턴)],
  [#text("nextra",font:"Courier New") : 허용되는 추가 극성 미스핏의 수],
  [#text("ntotal",font:"Courier New") : 허용되는 총 극성 미스핏의 최소 개수],
  [#text("qextra",font:"Courier New") : 허용되는 추가 진폭  미스핏의 최소 개수],
  [#text("qtotal",font:"Courier New") : 허용되는 총 진폭 미스핏의 최소 개수],
  )
  - Outputs
   #list(marker: ([•]),
   [#text("nf", font:"Courier New") : 찾아낸 단층면해의 수],
   [#text("strike(min(maxout, nf)", font:"Courier New")) : 주향],
   [#text("dip(min(maxout, nf)", font:"Courier New")) : 경사],
   [#text("rake(min(maxout, nf)", font:"Courier New")) : 미끌림각],
   [#text("faults(3, min(maxout, nf)", font:"Courier New")) : 단층의 법선 벡터],
   [#text("slips(3, min(maxout, nf)", font:"Courier New")) : Slip 벡터],
   )
- Computing the preferred, or most probable, mechanism
 - 계산으로부터 도출된 단층면해들은 최적의 단층면해를 결정하거나 해의 품질을 결정하는데에 사용됨 \ #zz 최적의 단층면해는 이상치들이 제거된 이후의 적합한 단층면해들로부터 평균으로 계산됨 \ #zz 두 가지의 불확실성이 계산됨 \ #zz 적합한 nodal plane과 최적의 nodal plane 간 RMS 차이와 \ #zz  사용자가 정의한 '가까운' 각도를 기준으로 최적의 단층면해가 실제 단층면해와 '가까운' 정도 \ #zz 이상치 군집이 존재할 시에, 이 이상치들로부터 대체 해가 발견될 수 있고, 이 때 최소 확률을 설정해 확률이 낮은 해는 무시할 수 있음
 #sourcecode[
    ```Fortran
    subroutine MECH_PROB(nf, normlin, norm2in, cangle, str_avg, dip_avg, rak_avg, prob, rms_diff)
    ```]
  - input
   #list(marker: ([•]),
  [#text("nf") : 단층 면의 수 ],
  [#text("norm1(3,nf)") : 단층면의 법선 벡터],
  [#text("norm2(3,nf)") : 보조 단층면의 Slip/법선 vector],
  [#text("cangle") : cangle 보다 작은 각도를 가질 때, 단층면해가 실제 단층면해와 '가깝다'고 여길 수 있음],
  [#text("prob_max") : 다수의 해에 대한 최소 확률],)
  - Output
   #list(marker: ([•]),
  [#text("nstln") : 출력되는 해의 개수 ],
  [#text("str_avg(nstln)") : 각 단층면해의 주향],
  [#text("dip_avg(nstln)") : 각 단층면해의 경사],
  [#text("rak_avg(nstln)") : 각 단층면해의 미끌림각],
  [#text("prob(nstln)") : 해의 평균에 '가까운' 해들의 비율],
  [#text("rms_diff(2,nstln)") : 모든 단층면의 평균 단층면에 대한 RMS 각 오차(1 = 주단층면, 2 = 보조단층면)],)
- Computing the data misfit for the preferred mech
 - 최적의 단층면해를 찾는 마지막 과정은 데이터의 미스핏을 찾는 것 \ #zz P파의 초동 극성과 함께 S/P 진폭비가 사용되는지 여부에 따라 별개의 유사한 서브루틴이 사용됨 \ #zz 입력값으로는 관측소 별 초동 극성과 진폭비, 방위각과 출발각, 최적의 메커니즘을 이용 \ #zz 출력값은 극성 미스핏의 가중치 비율 #text("mfrac", font: "Courier New"), 관측소의 분포 비율 #text("stdr", font: "Courier New") \ #zz 만약 S/P 진폭비가 사용되면 평균 $log_10 ("S/P")$ 미스핏이 #text("mavg", font: "Courier New") 로 출력
 - P파의 초동 극성만 이용할 경우 `GET_MISF` 서브루틴을 이용하며, 다음과 같은 입/출력값을 가짐
 #sourcecode[
    ```Fortran
    subroutine GET_MISF(npol, p_azi_mc, p_the_mc, p_pol, p_qual, str_avg, dip_avg, rak_avg, mfrac, stdr)
    ```]
 - Inputs
   #list(marker: ([•]),
  [#text("npol", font:"Courier New") : 초동 극성의 개수],
  [#text("p_azi_mc(npol)", font:"Courier New") : 방위각],
  [#text("p_the_mc(npol)", font:"Courier New") : 출발각],
  [#text("p_pol(npol)", font:"Courier New") : 초동 극성],
  [#text("p_qual(npol)", font:"Courier New") : 초동 극성의 품질],
  [#text("str_avg, dip_avg, rak_avg", font:"Courier New") : 최적의 메커니즘],)
 - Outputs
   #list(marker: ([•]),
  [#text("mfrac", font:"Courier New") : 극성 미스핏의 가중치 비율],
  [#text("stdr", font:"Courier New") : 관측소 분포 비율],)
 - P파의 초동 극성과 S/P 진폭비를 모두 이용할 경우 `GET_MISF_AMP` 서브루틴을 이용
 #sourcecode[
    ```Fortran
    subroutine GET_MISF_AMP(npol, p_azi_mc, p_the_mc, sp_ratio, p_pol, str_avg, dip_avg, rak_avg, mfrac, mavg, stdr)
    ```]
  - Inputs
   #list(marker: ([•]),
  [#text("npol", font:"Courier New") : 초동 극성의 개수],
  [#text("p_azi_mc(npol)", font:"Courier New") : 방위각],
  [#text("p_the_mc(npol)", font:"Courier New") : 출발각],
  [#text("sp_ratio(npol)", font:"Courier New") : S/P 진폭비],
  [#text("p_pol(npol)", font:"Courier New") : 초동 극성],
  [#text("str_avg, dip_avg, rak_avg", font:"Courier New") : 최적의 메커니즘],)
  - Outputs
   #list(marker: ([•]),
  [#text("mfrac", font:"Courier New") : 극성 미스핏의 가중치 비율],
  [#text("mavg", font:"Courier New") : 평균 $log_10 ("S/P")$ 미스핏],
  [#text("stdr", font:"Courier New") : 관측소 분포 비율],)
== Input and Data Preparation:

== Include Files:


== Output:



#pagebreak()
= FILE FORMATS

= Input Files
== P-polarity Files: