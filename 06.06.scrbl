;06.06.scrbl
;6.6 赋值和重定义
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          "guide-utils.rkt")

@title[#:tag "module-set"]{赋值和重定义}

在一个模块的变量定义上的 @racket[set!]使用，仅限于定义模块的主体。也就是说，一个模块可以改变它自己定义的值，这样的变化对于导入模块是可见的。但是，一个导入上下文不允许更改导入绑定的值。

@examples[
(module m racket
  (provide counter increment!)
  (define counter 0)
  (define (increment!)
    (set! counter (add1 counter))))
(require 'm)
(eval:alts counter (eval 'counter))
(eval:alts (increment!) (eval '(increment!)))
(eval:alts counter (eval 'counter))
(eval:alts (set! counter -1) (eval '(set! counter -1)))
]

在上述例子中，一个模块可以给别人提供一个改变其输出的能力，通过提供一个修改函数实现，如@racket[increment!]。

禁止导入变量的分配有助于支持程序的模块化推理。例如，在模块中，

@racketblock[
(module m racket
  (provide rx:fish fishy-string?)
  (define rx:fish #rx"fish")
  (define (fishy-string? s)
    (regexp-match? rx:fish s)))
]

@racket[fishy-string?]函数将始终匹配包含“fish”的字符串，不管其它模块如何使用@racket[rx:fish]绑定。从本质上来说，它帮助程序员的原因是，禁止对导入的赋值也允许更有效地执行许多程序。

在同一行中，当一个模块不包含@racket[set!]，在模块中定义的特定标识符，那该标识符被认为是一个@defterm{常数（constant）}，不能更改——即使重新声明该模块。

因此，通常不允许重新声明模块。对于基于文件的模块，简单地更改文件不会导致任何情况下的重新声明，因为基于文件的模块是按需加载的，而先前加载的声明满足将来的请求。它可以使用Racket的反射支持重新声明一个模块，而非文件模块可以重新在@tech{REPL}中声明；在这种情况下，如果涉及一个以前的静态绑定，重新申明可能失败。

@interaction[
(module m racket
  (define pie 3.141597))
(require 'm)
(module m racket
  (define pie 3))
]

作为探索和调试目的，Racket反射层提供了一个@racket[compile-enforce-module-constants]参数来使常量的执行无效。

@interaction[
(compile-enforce-module-constants #f)
(module m2 racket
  (provide pie)
  (define pie 3.141597))
(require 'm2)
(module m2 racket
  (provide pie)
  (define pie 3))
(compile-enforce-module-constants #t)
(eval:alts pie (eval 'pie))
]