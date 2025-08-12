" Either not at the start of the line, or otherwise not followed by a colon
syntax match markdownFootnoteZero  /\v(.@1<=\[\^0\])|(^\[\^0\]:@!)/ conceal cchar=⁰
syntax match markdownFootnoteOne   /\v(.@1<=\[\^1\])|(^\[\^1\]:@!)/ conceal cchar=¹
syntax match markdownFootnoteTwo   /\v(.@1<=\[\^2\])|(^\[\^2\]:@!)/ conceal cchar=²
syntax match markdownFootnoteThree /\v(.@1<=\[\^3\])|(^\[\^3\]:@!)/ conceal cchar=³
syntax match markdownFootnoteFour  /\v(.@1<=\[\^4\])|(^\[\^4\]:@!)/ conceal cchar=⁴
syntax match markdownFootnoteFive  /\v(.@1<=\[\^5\])|(^\[\^5\]:@!)/ conceal cchar=⁵
syntax match markdownFootnoteSix   /\v(.@1<=\[\^6\])|(^\[\^6\]:@!)/ conceal cchar=⁶
syntax match markdownFootnoteSeven /\v(.@1<=\[\^7\])|(^\[\^7\]:@!)/ conceal cchar=⁷
syntax match markdownFootnoteEight /\v(.@1<=\[\^8\])|(^\[\^8\]:@!)/ conceal cchar=⁸
syntax match markdownFootnoteNine  /\v(.@1<=\[\^9\])|(^\[\^9\]:@!)/ conceal cchar=⁹
