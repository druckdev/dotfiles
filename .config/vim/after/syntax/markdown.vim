" Either not at the start of the line, or otherwise not followed by a colon
syntax match markdownFootnoteZero  /\v(.\zs\[\^0\])|(^\[\^0\]\ze([^:]|$))/ conceal cchar=⁰
syntax match markdownFootnoteOne   /\v(.\zs\[\^1\])|(^\[\^1\]\ze([^:]|$))/ conceal cchar=¹
syntax match markdownFootnoteTwo   /\v(.\zs\[\^2\])|(^\[\^2\]\ze([^:]|$))/ conceal cchar=²
syntax match markdownFootnoteThree /\v(.\zs\[\^3\])|(^\[\^3\]\ze([^:]|$))/ conceal cchar=³
syntax match markdownFootnoteFour  /\v(.\zs\[\^4\])|(^\[\^4\]\ze([^:]|$))/ conceal cchar=⁴
syntax match markdownFootnoteFive  /\v(.\zs\[\^5\])|(^\[\^5\]\ze([^:]|$))/ conceal cchar=⁵
syntax match markdownFootnoteSix   /\v(.\zs\[\^6\])|(^\[\^6\]\ze([^:]|$))/ conceal cchar=⁶
syntax match markdownFootnoteSeven /\v(.\zs\[\^7\])|(^\[\^7\]\ze([^:]|$))/ conceal cchar=⁷
syntax match markdownFootnoteEight /\v(.\zs\[\^8\])|(^\[\^8\]\ze([^:]|$))/ conceal cchar=⁸
syntax match markdownFootnoteNine  /\v(.\zs\[\^9\])|(^\[\^9\]\ze([^:]|$))/ conceal cchar=⁹
