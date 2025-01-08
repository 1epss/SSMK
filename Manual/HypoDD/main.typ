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
  main-color: "4DA6FF", //set the main color
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
 - 이중 차분법은 두 지진의 진원 간격이 지진-관측소까지의 거리 및 불규질한 속도 모델의 길이 척도에 비해 작을 경우, 진원 지역과 공통의 관측소 사이 파선 경로가 거의 모든 경로에 걸쳐 유사하다는 점을 이용한다. 이 경우에, 하나의 관측소에 관측한 두 지진의 주행시간 차이는 두 지진 간의 공간적 간격에 기인한다고 높은 정확도로 추정할 수 있다. 
 - 이중 차분 방정식은 가이거의 방정식을 차분함으로서 만들어지며, 따라서 진원의 위치를 결정할 수 있다. 이를 통해, 관측한 주행시간과 공통 관측소에서의 두 지진의 계산된 주행시간 간 잔차는 각 지진의 주행시간을 편미분함으로서 진원 위치와 진원시의 상대적인 조정과 관련된다. HypoDD는 속도가 깊이에만 의존하는 층상 속도 구조모델을 이용해 현재 진원의 위치로부터 지진파 위상이 기록된 관측소까지의 주행시간을 계산한다. 각 관측소에서의 지진쌍들에 대한 이중 차분의 잔차는 SVD나 LSQR과 같은 방법을 사용한 가중 최소제곱법으로 최소화된다. 인접한 진원 쌍 간의 벡터 차를 반복적으로 조정함으로써 해를 구할 수 있고, 각 반복 후 진원의 위치와 편미분값이 갱신된다. 알고리즘에 관한 자세한 내용은 Waldhauser and Ellsworth (2000) 에서 확인할 수 있다.
 - 이중 차분 방정식을 이용해 진원 결정 문제를 선형화하면, 리시버 쪽 구조와 관련된 Common mode 오류가 상쇄된다. 따라서 진원 영역 외부에 위치한 파선 경로의 부분에 대해 관측소의 보정이나 예측된 주행시간의 높은 정확도를 필요로 하지 않게 된다. 이 접근법은 특히 지진이 밀집되어 분포하는 양상으로 발생하는 지역에 대해 유용하게 사용되며, 즉 이웃한 지진 간 거리가 몇 백 미터에 불과한 지역에서 유용하게 사용된다. 1997년 Long Valley caldera, California에서 발생한 약 1만개의 지진에 대해, 이중 차분 진원 결정이 일반적인 JHD 진원 결정보다 더 개선된 결과가 Figure 1에 나타나있다. 왼쪽 그림에서 JHD 진원 결정 방식이 지진 활동이 분산적으로 나타남을 보여주는 반면, 오른쪽 그림의 이중 차분 진원 결정은 활성 단층면의 위치와 같은 구조적인 세부 사항을 뚜렷한 진원의 형태로 선명하게 드러낸다.
 - 이중 차분법은 지진 카탈로그로부터 ordinary 발췌된 위상의 어느 조합이나 P/S파 위상의 상호상관을 통해 높은 정확도의 미분된 주행시간을 사용 가능하게끔 한다. 전자는 미분된 주행시간으로 표현되어, 양쪽 타입의 데이터에 모두 같은 방정식이 사용되어진다. 주행시간의 차이는 사용가능한 데이터에 대해 가능한 모든 진원 쌍들을 연결하기 위해 형성된다. 동적 가중치 방식을 통해 서로 다른 데이터 품질과 측정 정확도를 사용할 수 있으며, 이에 따라 상관된 지진 군집(멀티플렛) 내 지진 간 거리는 차등 도달 시간 데이터의 정확도로 결정되고, 멀티플렛과 상관되지 않은 지진 간의 상대적 위치는 카탈로그 데이터의 정확도로 결정된다.
 - HypoDD를 이용한 진원위치의 재결정은 두 단계로 이루어진다. 먼저 지진 쌍에 대한 주행 시간 차이를 계산하기 위해, 카탈로그의 위상 데이터 및/또는 파형 데이터를 분석한다. 지진 간의 연결을 최적화하고 데이터셋의 중복을 최소화하기 위해 데이터의 선별이 필요하다. 카탈로그의 위상 데이터를 전처리하는 방법은 2절에서 설명한다.
 - 이후 첫 번째 단계에서 생성된 차등 주행시간 데이터를 사용해 이중 차분 진원 재결정을 수행한다. hypoDD에 의해 수행되는 이 과정은 각 지진을 이웃 지진과 연결하는 벡터의 네트워크가 수치적인 불안정성을 유발할 수 있는 약한 연결을 포함하지 않도록 보장한 이후, 진원의 분리를 계산하며, 자세한 내용은 3절에서 설명한다. 최소제곱법을 사용하는 모든 절차와 마찬가지로, hypoDD로 도출된 해는 신중히 평가해야 하며 결과를 비판 없이 수용해서는 안 된다.
#pagebreak()
= ph2dt를 이용한 데이터 전처리
- Data Preprocessing Using ph2dt 
 - HypoDD를 사용함에 있어 가장 중요한 데이터는 공통 관측소에서 지진 쌍들에 대해 측정한 주행시간의 차이다. 이 데이터들은 거의 모든 네트워크에서 제공되는 지진 카탈로그나 파형의 상호상관을 통해 얻을 수 있다. 두 경우 모두 최소제곱법 해의 안정성을 보장하고, 지진 들 사이 연결성을 최적화하기 위해 지진 쌍에 대한 도달 시간 차이가 필요하다. 이 절에서는 카탈로그의 P/S파의 위상 데이터를 hypoDD의 입력 파일로 변환하는 프로그램인 ph2dt 에 대해 설명한다.
 -  ph2dt는 공통 관측소에서 주행시간 정보를 가진 지진 쌍들을 찾기 위해 카탈로그의 P/S파 위상 데이터들을 검색하고, 지진파 위상 쌍의 품질과 지진 간 연결성을 최적화하기 위해, 이 데이터들을 서브샘플링한다. 이상적으로, 지진 간 연결 네트워크를 구축하여, 어느 한 지진부터 다른 지진까지 쌍으로 연결된 지진들의 체인이 존재하도록 하며, 연결된 지진 간의 거리는 가능한 한 작게 유지하도록 한다. ph2dt 는 각 지진으로부터 MAXSEP에 의해 정의되는 검색 반경 이내의 최대 MAXNGH개의 이웃 지진에 링크를 세움으로써 네트워크를 구축한다(볼드체로 작성한 변수명은 권장값과 함께 부록 A에 나열되어 있다.). 인접 지진의 최대 개수를 얻기 위해서는 '강한' 인접 지진만 고려되는데, 즉 MINLNK 위상 쌍보다는 많이 연결되어짐을 의미한다. '약한' 인접 지진, 즉 MINLNK 위상 쌍보다 적은 수의 인접 지진 역시 선택되긴 하지만 강한 인접 지진으로는 고려되지 않는다. 강한 연결은 전형적으로 8개 이상의 관측으로부터 정의된다(자유도의 각 차원당 하나의 관측값). 그러나, 각 지진 쌍에 대한 다수의 관측은 항상 안정된 해를 제공하는 것은 아니며, 해는 관측소의 분포와 같은 요인에 크게 의존한다.
 - 인접한 지진들을 찾기 위해, 최근접 이웃 접근법이 사용된다. 이 접근법은 지진들이 검색 반경(MAXSEP) 이내 랜덤하게 분포해있는 경우(반경이 진원 결정 루틴의 오차와 비슷한 경우) 가장 적합한 방법으로 여겨진다. Delauney 테셀레이션과 같은 다른 접근법들은 지진 활동이 넓은 범위에서 강하게 군집되어 나타나는 경우나, 사전 진원 위치의 오차가 검색 반경보다 훨씬 작을 경우에 적합하게 사용될 수 있다. 그러나 검색 반경은 지구물리학적으로 의미있는 수치를 초과해서는 안된다. 두 지진 간 진원의 분리는 관측소-지진 거리과 속도 불균질성의 길이 척도에 비해 작아야 한다.  약 10km의 반경은 다수의 지역에서 시작하기에 적절한 수치이다. 
 - 수백개의 지진에 대해 고려하다라도, 가능한 이중 차분의 관측 수(지연 시간)은 매우 커질 수 있다. 이 문제를 피하기 위한 방법으로 각 지진 쌍에 대해 연결의 수를 제한하는 것이 있다. 즉, 각 지진 쌍에 대해 선택할 최소-최대 관측 수 (MINOBS, MAXOBS)를 정의하는 것이다. 많은 수의 지진의 경우, MINOBS를 MINLNK에 동일하게 설정하여 강하게 연결된 지진 쌍들만 고려하는 방법이 있다. 예를 들어 1만개의 잘 연결된 지진들이 있다고 하면, ph2dt는 다음과 같은 파라미터(MAXNGH = 8, MINLNK = 8, MINOBS = 8, MAXOBS = 50)와 함께 100만개의 지연시간을 출력할 것이다. 반면에, 조밀한 군집을 형성하는 작은 수의 지진과 같은 경우, MINOBS =1, MAXOBS = 관측소의 수, MAXNGH = 지진의 수로 설정하여 가능한 모든 위상 쌍을 선택할 수 있다. 
 - 지진 쌍 사이 진원 깊이의 오차를 조절하기 위해, 수직적인 slowness 수치의 범위가 요구된다. 지진 쌍에 가까운 관측소들은 보통 두 지진 사이 진원 깊이의 오차를 조절하는데 가장 효과적으로 여겨진다. 그러므로, ph2dt는 지진 쌍 별 최대 관측의 수(MAXOBS)에 도달할 때 까지 점점 더 먼 거리의 관측소에서 관측값을 선택하게 된다. 이과정에서, 피크 가중치가 MINWGHT(0 이상)보다 작은 지진파의 위상은 무시된다. 다시 말해, MINOBS 미만의 관측값을 가진 지진 쌍의 링크는 무시된다.
 - 음수의 값을 가지는 가중치는 

A negative weight is a flag to ph2dt to include these readings regardless of their absolute weight whenever the paired event also has observations of this phase at the particular station.
The preprocessing program ncsn2pha (Appendix C) automatically marks reading weights with a negative sign whenever the diagonal element of the data resolution matrix, or Hat matrix (data importance reported by Hypoinverse (Klein, 1989, and personal communication, 2001)) is larger than 0.5. 
Users without importance information are encouraged to consider preprocessing the input to ph2dt to flag critical station readings. 
Readings with negative weights are used in addition to the MAXOBS phase pairs with positive weights.
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