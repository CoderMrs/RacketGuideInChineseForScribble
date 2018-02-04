;07.01.03.scrbl
;7.1.3 嵌套合约的测试
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "utils.rkt"
          (for-label racket/base
                     racket/contract))

@title[#:tag "intro-nested"]{嵌套合约的测试}

在许多情况下，在模块边界上附加合约是有意义的。然而，能够以比模块更细致的方式使用合约通常是便利的。@racket[define/contract]表允许这种使用：

@racketmod[
racket

(define/contract amount
  (and/c number? positive?)
  150)

(+ amount 10)
]

在这个例子中，@racket[define/contract]表在@racket[amount]定义和它周围的上下文之间建立了一个合约边界。换言之，这里的双方是包含它的定义和模块。

创造这些@emph{嵌套的合约边界（nested contract boundaries）}的表的使用有时是微妙的，因为他们可能会有意想不到的影响性能或指责似乎不直观的一方。这些微妙之处在《define/contract和->的使用》（Using define/contract and ->）和《合同的边界（@secref["simple-nested"]）和define/contract（@ctc-link["gotcha-nested"]）》（Contract boundaries and define/contract
）中得到了解释。