;07.02.04.scrbl
;7.2.4 扩展自己的合约
#lang scribble/doc
@(require scribble/manual
          scribble/eval
          scribble/core
          racket/list
          scribble/racket
          "guide-utils.rkt"
          "utils.rkt"
          (for-label racket/contract))

@title[#:tag "own"]{扩展自己的合约}

@racket[deposit]函数将给定的数字添加到@racket[amount]中。当函数的合约阻止客户机将它应用到非数字时，合约仍然允许他们把这个函数应用到复数、负数或不精确的数字中，但没有一个能合理地表示钱的金额。

合约系统允许程序员定义自己的合约作为函数：

@racketmod[
racket
  
(define (amount? a)
  (and (number? a) (integer? a) (exact? a) (>= a 0)))

(provide (contract-out
          (code:comment "an amount is a natural number of cents")
          (code:comment "is the given number an amount?")
          [deposit (-> amount? any)]
          [amount? (-> any/c boolean?)]
          [balance (-> amount?)]))
  
(define amount 0)
(define (deposit a) (set! amount (+ amount a)))
(define (balance) amount)
]

这个模块定义了一个@racket[amount?]函数，并将其作为@racket[->]合约内的合约使用。当客户机用@racket[(->
amount? any)]调用@racket[deposit]函数作为导出时，它必须提供一个确切的非负整数，否则@racket[amount?]函数应用到参数将返回@racket[#f]，这将导致合约监控系统指责客户端。类似地，服务器模块必须提供一个精确的非负整数作为@racket[balance]的结果，以保持无可指责。

当然，将通信通道限制为客户机不明白的值是没有意义的。因此，模块也导出@racket[amount?] 断言本身，用一个合约表示它接受任意值并返回布尔值。

在这种情况下，我们也可以使用@racket[natural-number/c]代替@racket[amount?]，因为它意味着完全相同的检查：

@racketblock[
(provide (contract-out
          [deposit (-> natural-number/c any)]
          [balance (-> natural-number/c)]))
]

接受一个参数的每一个函数都可以当作断言，从而用作合约。结合现有的检查到一个新的，但是，合同组合@racket[and/c]或@racket[or/c]往往是有用的。例如，这里还有另一种途径去写上述合约：

@racketblock[
(define amount/c 
  (and/c number? integer? exact? (or/c positive? zero?)))

(provide (contract-out
          [deposit (-> amount/c any)]
          [balance (-> amount/c)]))
]

其它值也有作为合约的双重义务。例如，如果一个函数接受一个数值或@racket[#f]，@racket[(or/c number?  #f)]就够了。同样，@racket[amount/c]合约也可以用@racket[0]代替@racket[zero?]来写。如果使用正则表达式作为合约，则合约接受与正则表达式匹配的字符串和字节字符串。

当然，你可以把你自己的合约执行函数像@racket[and/c]一样组合，这儿有一个用于创建从银行记录字符串的模块：

@racketmod[
racket

(define (has-decimal? str)
  (define L (string-length str))
  (and (>= L 3)
       (char=? #\. (string-ref str (- L 3)))))

(provide (contract-out
          (code:comment "将一个随机数转换为字符串")
          [format-number (-> number? string?)]

          (code:comment "将一个数字转换成一个带有小数点的字符串，")
          (code:comment "如美国货币的数量。")
          [format-nat (-> natural-number/c
                          (and/c string? has-decimal?))]))
]

导出函数@racket[format-number]的合约指定函数接受一个数字并生成一个字符串。导出函数@racket[format-nat]的合约比@racket[format-number]的合约更有趣。它只接受自然数。它的范围合约承诺在右边的第三个位置带有一个@litchar{.}的字符串。

如果我们希望加强@racket[format-nat]的值域合约的承诺，以便它只接受带数字和一个点的字符串，我们可以这样写：

@racketmod[
racket

(define (digit-char? x) 
  (member x '(#\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9 #\0)))

(define (has-decimal? str)
  (define L (string-length str))
  (and (>= L 3)
       (char=? #\. (string-ref str (- L 3)))))

(define (is-decimal-string? str)
  (define L (string-length str))
  (and (has-decimal? str)
       (andmap digit-char?
               (string->list (substring str 0 (- L 3))))
       (andmap digit-char?
               (string->list (substring str (- L 2) L)))))

....

(provide (contract-out
          ....
          (code:comment "convert an  amount (natural number) of cents")
          (code:comment "into a dollar-based string")
          [format-nat (-> natural-number/c 
                          (and/c string? 
                                 is-decimal-string?))]))
]

另外，在这种情况下，我们可以使用正则表达式作为合约：

@racketmod[
racket

(provide 
 (contract-out
  ....
  (code:comment "convert an  amount (natural number) of cents")
  (code:comment "into a dollar-based string")
  [format-nat (-> natural-number/c
                  (and/c string? #rx"[0-9]*\\.[0-9][0-9]"))]))
]