;07.07.scrbl
;7.7 额外的例子
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "utils.rkt"
          (for-label racket/contract
                     racket/gui))

@title[#:tag "contracts-examples"]{额外的例子}

本节说明了Racket合约执行的当前状态，与一系列来自于@italic{《合约设计》（Design by Contract）}@cite["Mitchell02"]的例子。

由米切尔（Mitchell）和麦金（McKim）的合约DbC设计原则源于1970年代风格的代数规范。DbC的总体目标是指定一个在观察成员里的代数的构造者。当我们将米切尔和麦金的术语用形式表达，我们用最适用的方法，我们保留他们的术语“类”（classes）和“对象”（objects）：

@itemize[
@item{@bold{从命令中分离查询。}

一个@italic{查询（query）}返回一个结果，但不会改变对象的可观察属性。一个@italic{命令（command）}更改对象的可见属性，但不返回结果。在应用程序实现中，命令通常返回同一个类的新对象。}

@item{@bold{从派生查询中分离基本查询。}

一个@italic{派生查询（derived query）}返回一个可根据基本查询计算的结果。}

@item{@bold{对于每个派生查询，编写一个后置条件契约，该契约根据基本查询指定结果。}}

@item{@bold{对于每个命令，编写一个后置条件合约，指定基本查询中对可见属性的更改。}}

@item{@bold{对于每个查询和命令，决定一个合适的条件合约。}}
 ]

以下各部分对应于米切尔和麦金的书中的一章（但不是所有章节显示在这里）。我们建议您先阅读合约（在第一个模块的结尾），然后是实现（在第一个模块中），然后是测试模块（在每个部分的结尾）。

米切尔和麦金利用Eiffel语言作为底层的编程语言，采用传统的命令式编程风格。我们的长期目标是将他们的例子变成Racket的程序，Racket面向结构及Racket的类系统势在必行。

注：模仿米切尔和麦金的非正式的概念parametericity（参数化多态性），我们用一流的合约。在一些地方，使用一流的合约提高了对米切尔和麦金的设计（见注释接口）。

@;---------------------------------------------------------------
@include-section["07.07.01.scrbl"]
@include-section["07.07.02.scrbl"]
@include-section["07.07.03.scrbl"]
@include-section["07.07.04.scrbl"]