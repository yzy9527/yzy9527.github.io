---
title: CSRF攻击
date: 2020-11-20 20:22:32
categories:
 - Web安全
 - CSRF攻击
---
# CSRF

 - Cross Site Request Forgy
 - 跨站请求伪造

一种挟制用户在当前已登录的Web应用程序上执行非本意的操作的攻击方法；简单地说，是攻击者通过一些技术手段欺骗用户的浏览器去访问一个自己曾经认证过的网站并运行一些操作（如发邮件，发消息，甚至财产操作如转账和购买商品）。
 > `XSS` 是指本网站运行了来自其他网站的脚本； `SCRF`是指其它网站对本网站产生了影响

## 危害

 - 利用用户登录态 
 - 用户不知情
 - 完成业务请求
 - 盗取用户资料
 - 冒充用户发帖背锅
 - 损害网站名誉

## CSRF攻击案例

 - qq游戏购买道具

    `http://account.play.qq.com:8080//cgi-bin/buyitem_present_yxb1?item_id=56&item_num=1`

    上面接口使用了一个get请求，如果用户登录了qq，则会购买ID为56的道具一件，给用户造成了实际的损失（一点就爆炸，现已修复）

    <!--more-->

 - qq音乐分享到腾讯微博
    
    通过点击微博内的链接，就会进入到攻击者的网站，该网站中包含以下代码，此时用户就会受到csrf攻击
    ![](https://qiniu.xiaoxilao.com/20201115145459.png)

## CSRF攻击防御

### 1. SameSite 属性

Cookie 的`SameSite`属性用来限制第三方 Cookie，从而减少安全风险。它可以设置三个值

- Strict
- Lax
- None

**Strict**

Strict最为严格，完全禁止第三方 Cookie，跨站点时，任何情况下都不会发送 Cookie。换言之，只有当前网页的 URL 与请求目标一致，才会带上 Cookie。
    
    Set-Cookie: CookieName=CookieValue; SameSite=Strict;
    
这个规则过于严格，可能造成非常不好的用户体验。比如，当前网页有一个 GitHub 链接，用户点击跳转就不会带有 GitHub 的 Cookie，跳转过去总是未登陆状态。

**Lax**

`Lax`规则稍稍放宽，大多数情况也是不发送第三方 Cookie，但是导航到目标网址的 Get 请求除外。

    Set-Cookie: CookieName=CookieValue; SameSite=Lax;

导航到目标网址的 GET 请求，只包括三种情况：链接，预加载请求，GET 表单

请求类型|示例|正常情况|Lax
---|:--:|---:|---:
链接|`<a href="..."></a>`|发送 Cookie|发送 Cookie
预加载|`<link rel="prerender" href="..."/>`|发送 Cookie|发送 Cookie
GET 表单|`<form method="GET" action="...">`|发送 Cookie|发送 Cookie
POST 表单|`<form method="POST" action="...">`|发送 Cookie|不发送
iframe|`<iframe src="..."></iframe>`|发送 Cookie|不发送
AJAX|`$.get("...")`|发送 Cookie|不发送
Image|`<img src="...">`|发送 Cookie|不发送

**None**

Chrome 计划将`Lax`变为默认设置。这时，网站可以选择显式关闭`SameSite`属性，将其设为`None`。不过，前提是必须同时设置`Secure`属性（Cookie 只能通过 HTTPS 协议发送），否则无效。

下面的设置无效。

    Set-Cookie: widget_session=abc123; SameSite=None

下面的设置有效。

    Set-Cookie: widget_session=abc123; SameSite=None; Secure

### 2.验证码和token

验证码需要用户参与，必须访问前端网站，后台比较当前用户输入的验证码和下发的验证码是否一致，可有效防止csrf攻击;


### 3.refere

验证refer,判断请求来源，禁止来自第三方的请求











