### 简介
> validator 包验证器基于标签对结构和各个字段实现值验证。
> 它还可以处理嵌套结构的跨字段和跨结构验证，并具有深入研究任何类型的数组和映射的能力。

### 验证函数返回类型错误
嗯。。。validator对参数的验证，

### 自定义字段验证
```go
// Structure
func customFunc(fl validator.FieldLevel) bool {

	if fl.Field().String() == "invalid" {
		return false
	}

	return true
}

validate.RegisterValidation("custom tag name", customFunc)
// NOTES: using the same tag name as an existing function
//        will overwrite the existing one
```

### 可以用于处理跨字段验证的tag
```
- eqfield
- nefield
- gtfield
- gtefield
- ltfield
- ltefield
- eqcsfield
- necsfield
- gtcsfield
- gtecsfield
- ltcsfield
- ltecsfield
```
以上后六个可以用于跨字段的验证，
eg:
```go
type Inner struct {
	StartDate time.Time
}

type Outer struct {
	InnerStructField *Inner
	CreatedAt time.Time      `validate:"ltecsfield=InnerStructField.StartDate"`
}
```
### 多个验证器
字段上的多个验证器将按照定义的顺序进行处理。例：
```go
type Test struct {
	Field `validate:"max=10,min=1"`
}

// 将先检查max，然后再检查min
```
不会处理错误的验证器定义
```go
type Test struct {
	Field `validate:"min=10,max=0"`
}

// 这个定义永远不会生效
```

### 验证器tag的默认符号
“,”和“|”的默认符号，“,”是验证器的分隔，使用“0x2C”替代，“|”表示或，用“0x7C”替代

### 一些验证器
```
1. “-”                     跳过此字段验证
2. “|”                     验证器之间，表示或
3. “structonly”
4. “nostructlevel”
5. “omitempty”             可为空，结合其他验证器，要么为空要么验证其他，区别于required，输入字段默认值会省略不验证
6. “dive”
7. “Keys & EndKeys”        用于字典结构的验证，结合dive，对整体和键值对的控制，可以嵌套
8. “required”              需要验证，区别于omitempty，输入字段默认值默认为没输入，如"",0等，可类型改为指针等解决
9. “required_with”
10. “required_with_all”
11. “required_without”
12. “isdefault”
13. “len”
14. “max”                  数字类型，小于等于；字符串类型，小于等于长度；切片字典和数组验证元素个数                                            
15. “min”                  数字类型，大于等于；字符串类型，大于等于长度；切片字典和数组验证元素个数                  输入字符串长度，字符个数相等
16. "eq"                   数字和字符串，需要等于所给value，切片等相同验证               
17. "ne"                   不等
18. "oneof"
19. "gt"                   数字类型，大于；字符串类型，大于长度；切片字典和数组验证元素个数，大于
20. "gte"                  相似同上
21. "lt"                   数字类型，小于；字符串类型，小于长度；切片字典和数组验证元素个数，小于
22. "lte"                  相似同上
23. "containsfield"
24. "excludesfield"
25. "unique"
26. "alpha"
27. "alphanum"
28. "alphaunicode"
29. "alphanumunicode"
30. "number"
31. "numeric"
32. "hexadecimal"
33. "hexcolor"
34. "lowercase"
35. "uppercase"
36. "rgb"
37. "rgba"
38. "hsl"
39. "hsla"
40. "email"
41. "json"
42. "file"
43. "url"
44. "uri"
45. "urn_rfc2141"
46. "base64"
47. "base64url"
```
- dive的example                  
```
# 1
[][]string with validation tag "gt=0,dive,len=1,dive,required"
// gt=0 will be applied to []
// len=1 will be applied to []string
// required will be applied to string
# 2
[][]string with validation tag "gt=0,dive,dive,required"
// gt=0 will be applied to []
// []string will be spared validation
// required will be applied to string
```
- keys,endkeys的example
```
# 1
map[string]string with validation tag "gt=0,dive,keys,eg=1|eq=2,endkeys,required"
// gt=0 will be applied to the map itself
// eg=1|eq=2 will be applied to the map keys
// required will be applied to map values
# 2
map[[2]string]string with validation tag "gt=0,dive,keys,dive,eq=1|eq=2,endkeys,required"
// gt=0 will be applied to the map itself
// eg=1|eq=2 will be applied to each array element in the the map keys
// required will be applied to map values
```

### 表格


|         标记         |                           标记说明                           | 例                                                           |
| :------------------: | :----------------------------------------------------------: | :----------------------------------------------------------- |
|       required       |                             必填                             | Field或Struct `validate:"required"`                          |
|      omitempty       |                           空时忽略                           | Field或Struct `validate:"omitempty"`                         |
|         len          |                             长度                             | Field `validate:"len=0"`                                     |
|          eq          |                             等于                             | Field `validate:"eq=0"`                                      |
|          gt          |                             大于                             | Field `validate:"gt=0"`                                      |
|         gte          |                           大于等于                           | Field `validate:"gte=0"`                                     |
|          lt          |                             小于                             | Field `validate:"lt=0"`                                      |
|         lte          |                           小于等于                           | Field `validate:"lte=0"`                                     |
|       eqfield        |                      同一结构体字段相等                      | Field `validate:"eqfield=Field2"`                            |
|       nefield        |                     同一结构体字段不相等                     | Field `validate:"nefield=Field2"`                            |
|       gtfield        |                      大于同一结构体字段                      | Field `validate:"gtfield=Field2"`                            |
|       gtefield       |                    大于等于同一结构体字段                    | Field `validate:"gtefield=Field2"`                           |
|       ltfield        |                      小于同一结构体字段                      | Field `validate:"ltfield=Field2"`                            |
|       ltefield       |                    小于等于同一结构体字段                    | Field `validate:"ltefield=Field2"`                           |
|      eqcsfield       |                     跨不同结构体字段相等                     | Struct1.Field `validate:"eqcsfield=Struct2.Field2"`          |
|      necsfield       |                    跨不同结构体字段不相等                    | Struct1.Field `validate:"necsfield=Struct2.Field2"`          |
|      gtcsfield       |                     大于跨不同结构体字段                     | Struct1.Field `validate:"gtcsfield=Struct2.Field2"`          |
|      gtecsfield      |                   大于等于跨不同结构体字段                   | Struct1.Field `validate:"gtecsfield=Struct2.Field2"`         |
|      ltcsfield       |                     小于跨不同结构体字段                     | Struct1.Field `validate:"ltcsfield=Struct2.Field2"`          |
|      ltecsfield      |                   小于等于跨不同结构体字段                   | Struct1.Field `validate:"ltecsfield=Struct2.Field2"`         |
|         min          |                            最大值                            | Field `validate:"min=1"`                                     |
|         max          |                            最小值                            | Field `validate:"max=2"`                                     |
|      structonly      |              仅验证结构体，不验证任何结构体字段              | Struct `validate:"structonly"`                               |
|    nostructlevel     |                   不运行任何结构级别的验证                   | Struct `validate:"nostructlevel"`                            |
|         dive         |            向下延伸验证，多层向下需要多个dive标记            | [][]string `validate:"gt=0,dive,len=1,dive,required"`        |
| dive Keys & EndKeys  | 与dive同时使用，用于对map对象的键的和值的验证，keys为键，endkeys为值 | map[string]string `validate:"gt=0,dive,keys,eq=1\|eq=2,endkeys,required"` |
|    required_with     |            其他字段其中一个不为空且当前字段不为空            | Field `validate:"required_with=Field1 Field2"`               |
|  required_with_all   |              其他所有字段不为空且当前字段不为空              | Field `validate:"required_with_all=Field1 Field2"`           |
|   required_without   |             其他字段其中一个为空且当前字段不为空             | Field `validate:"required_without=Field1 Field2"             |
| required_without_all |               其他所有字段为空且当前字段不为空               | Field `validate:"required_without_all=Field1 Field2"`        |
|      isdefault       |                           是默认值                           | Field `validate:"isdefault=0"`                               |
|        oneof         |                           其中之一                           | Field `validate:"oneof=5 7 9"`                               |
|    containsfield     |                      字段包含另一个字段                      | Field `validate:"containsfield=Field2"`                      |
|    excludesfield     |                     字段不包含另一个字段                     | Field `validate:"excludesfield=Field2"`                      |
|        unique        |                是否唯一，通常用于切片或结构体                | Field `validate:"unique"`                                    |
|       alphanum       |            字符串值是否只包含 ASCII 字母数字字符             | Field `validate:"alphanum"`                                  |
|     alphaunicode     |               字符串值是否只包含 unicode 字符                | Field `validate:"alphaunicode"`                              |
|   alphanumunicode    |           字符串值是否只包含 unicode 字母数字字符            | Field `validate:"alphanumunicode"`                           |
|       numeric        |                  字符串值是否包含基本的数值                  | Field `validate:"numeric"`                                   |
|     hexadecimal      |                字符串值是否包含有效的十六进制                | Field `validate:"hexadecimal"`                               |
|       hexcolor       |              字符串值是否包含有效的十六进制颜色              | Field `validate:"hexcolor"`                                  |
|      lowercase       |                   符串值是否只包含小写字符                   | Field `validate:"lowercase"`                                 |
|      uppercase       |                   符串值是否只包含大写字符                   | Field `validate:"uppercase"`                                 |
|        email         |                字符串值包含一个有效的电子邮件                | Field `validate:"email"`                                     |
|         json         |                  字符串值是否为有效的 JSON                   | Field `validate:"json"`                                      |
|         file         |  符串值是否包含有效的文件路径，以及该文件是否存在于计算机上  | Field `validate:"file"`                                      |
|         url          |                   符串值是否包含有效的 url                   | Field `validate:"url"`                                       |
|         uri          |                   符串值是否包含有效的 uri                   | Field `validate:"uri"`                                       |
|        base64        |               字符串值是否包含有效的 base64值                | Field `validate:"base64"`                                    |
|       contains       |                    字符串值包含子字符串值                    | Field `validate:"contains=@"`                                |
|     containsany      |              字符串值包含子字符串值中的任何字符              | Field `validate:"containsany=abc"`                           |
|     containsrune     |                 字符串值包含提供的特殊符号值                 | Field `validate:"containsrune=☢"`                            |
|       excludes       |                   字符串值不包含子字符串值                   | Field `validate:"excludes=@"`                                |
|     excludesall      |                 字符串值不包含任何子字符串值                 | Field `validate:"excludesall=abc"`                           |
|     excludesrune     |                字符串值不包含提供的特殊符号值                | Field `validate:"containsrune=☢"`                            |
|      startswith      |                  字符串以提供的字符串值开始                  | Field `validate:"startswith=abc"`                            |
|       endswith       |                  字符串以提供的字符串值结束                  | Field `validate:"endswith=abc"`                              |
|          ip          |                字符串值是否包含有效的 IP 地址                | Field `validate:"ip"`                                        |
|         ipv4         |               字符串值是否包含有效的 ipv4地址                | Field `validate:"ipv4"`                                      |
|       datetime       |                 字符串值是否包含有效的 日期                  | Field `validate:"datetime"`                                  |