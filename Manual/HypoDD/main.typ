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