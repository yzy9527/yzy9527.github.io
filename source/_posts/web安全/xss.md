---
title: XSS攻击
date: 2020-11-13 22:12:12
categories:
 - Web安全
 - XSS攻击
---

安全问题：
 - 用户身份被盗用
 - 用户密码泄露
 - 用户资料被盗取
 - 网站数据库泄露
 - 其他
 
web 安全的重要性

- 直接面向用户
- 网站和用户安全是生命线
- 安全事故威胁企业生产、口碑甚至生存


# XSS (Cross Site Scripting)

 - 跨站脚本攻击

 > 为了防止简称和CSS冲突，故改为XSS
 
 ## xss分类
 
 - 反射型 （url直接注入）
 
    如url为`www.abc.com?sokey=<script>alert(1)</script>`,攻击者将上面的URL发送给其他用户时才会产生作用，此时攻击者会将这类url转为短网址;例如：`https://www.baidu.com/s?cl=3&tn=baidutop10&fr=top1000&wd=%E7%89%B9%E6%9C%97%E6%99%AE%E5%9B%A2%E9%98%9F%E4%BA%AE%E5%87%BA%E7%99%BE%E9%A1%B5%E9%80%89%E4%B8%BE%E6%AC%BA%E8%AF%88%E8%AF%81%E8%AF%8D&rsv_idx=2&rsv_dl=fyb_n_homepage&hisfilter=1`和 `http://dwz.win/WVm`是一样的，从而达到欺骗用户的目的

 - 存储性 （存储到DB后读取时注入）
    这类攻击不易被发现，且危害大，因为是存储到数据库中，所以其他用户访问这个网站时，都会受到攻击；例：在页面的评论区中评论内容并添加alert脚本，由于内容是存储到数据库中的，故其他用户每次访问都会受到攻击

    <!--more-->

## xss攻击注入点

 - html节点内容

   当网页中的某一个节点是动态生成的，里面包含用户的输入信息，有可能输入的信息包含脚本，从而导致xss攻击
    ![](https://qiniu.xiaoxilao.com/1605192471345_4.png)


 - HTML属性

    当某个HTML的节点的某个属性是由用户的输入数据组成的，那么这个用户的输入数据有可能包含脚本，或者越出这个属性的范围，从而导致xss攻击<br>
    例：用户的头像是通过get请求根据id来获取的，如
    `localhost:8989/?avatarid=9527`
    ```html
    <img src="/user/9527">
    ```
    后面追加
    `localhost:8989/?avatarid=9527"`
    ```html
    <img src="/user/9527" ">
    ```
    此时，如果输入时添加`onerror`,就可以看到弹窗了
    `localhost：8089/?avatarid= 1 "onerror="alert('123')`
    ```html
    <img src="/user/1" onerror="alert('123')">
    ```
 - js代码

    js代码中存在由后台注入的变量或者里面包含了用户输入的信息，这时候用户输入的信息有可能会改变js代码的逻辑，从而导致xss攻击<br>
    例：
    如后台指定输入字段生成script标签插入html
    `localhost:8989/?name=baidu"`
    此时html中
     ```html
     <script>
        var name = "baidu"
     </script>
    ```
    如果后面追加alert
    ` localhost:8989/?name=gaoshiqing";alert(1);"`
    ```html
    <script>
        var name = "gaoshiqing";alert(1);""
     </script>
    ```

- 富文本

    富文本中既要保留文本的格式又要去除可能造成xss攻击的代码，容易导致xss攻击



## XSS防御
1. 浏览器自带防御

    浏览器防御有限，自动防御反射型xss,当url的参数再次出现在页面中，浏览器就会进行拦截（参数出现在HTML内容或属性中）；
    ![](https://qiniu.xiaoxilao.com/20201112233112.png)

    > 在js中注入的参数，虽然出现在了url和页面中，但此时浏览器的xss防御机制并没有起作用；此外并不是所有的浏览器都支持防御

2. 对html内容和属性进行转义

    对用户的输入进行转义，有一下两种方法：
     - 在上传数据时进行转义
     - 在显示时进行转义

    ```js
    let escapehtml = function(str){
        if(!str) return '';
        str = str.replace(/&/g,'&amp;')
        str = str.replace(/</g,'&lt;')
        str = str.replace(/>/g,'&gt;')
        str = str.replace(/"/g,'&quto;')
        str = str.replace(/'/g,'&#39;')
    }
    ```
3. js转义

    防止用户或者后台在js中插入的数据可能突破`"`的边界，产生一个新的语句；

    - 对`"`和`\`进行转义,
        ```js
        str = str.replace(/\\/g,'\\\\')
        str = str.replace(/"/g,'\\"')
        ```
    - 对数据进行json转换

    例：以下为后台转义后返回

    `localhost:8989/?name=hello";alert(1);"`

    没有做任何处理时，生成了一条可执行代码
    ```html
    <script>
        var name = "hello";alert(1);""
    </script>
    ```
    对`"`转义后，`name`变成了字符串
    ```html
    <script>
        var name = "hello\";alert(1);\""
    </script>
    ```
    此时输入中添加`\`，后面的`/`直接变成了注释负，代码又满血复活

     `localhost:8989/?name=hello\";alert(1);//`

    ```html
    <script>
        var name = "hello\\";alert(1);//"
    </script>
    ```
    所以需对`"`和`/`同时进行转义，但为了防止有其他的情况出现，最好对用户的输入使用`JSON.stringify()`进行处理

4. 富文本

    富文本其实就是一大段的`HTML`，包含着许多的格式，因此无法对全部`HTML`进行转义，但保留`HTML`格式就要面临着`xss`攻击的风险；所以要对`HTML`进行过滤，过滤一般分为以下两种：

 - 黑名单
    主要是将一些`HTML`的标签或属性,如`script`、`onerror`进行删除；黑名单的实现相对简单，一般按照正则表达式去过滤就可以了，但其弊端在于`HTML`是一个非常繁杂和庞大的系统，稍不留神就会留下漏洞
    
 - 白名单
    只允许指定的标签和属性存在，比较彻底，但实现起来比较麻烦，它需要将`HTML`全部转换为数据结构，然后对这个数据结构进行过滤，再组装成`HTML`，数据结构类似下图
    ![](https://qiniu.xiaoxilao.com/20201113223738.png)
    也可以使用开源库 [js-xss](https://github.com/leizongmin/js-xss/blob/master/README.zh.md)

富文本的过滤主要在用户的输入时进行过滤，如果在输出的时候进行过滤可能会造成一些性能问题


## csp

"网页安全政策"（Content Security Policy，缩写 CSP）

CSP 的实质就是白名单制度，它指定哪些部分可以被执行，哪些部分不可以被执行

```js
Content-Security-Policy: default-src 'self'
```
上面代码限制所有的外部资源，都只能从当前域名加载。详情可参考[内容安全策略( CSP )](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/CSP)


