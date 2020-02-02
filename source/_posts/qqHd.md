---
title: ipad qq浏览器HD video标签劫持问题
date: 2019-10-27 17:22:13
---
问题来源：在升级iOS为12后，项目测试兼容性时发现，有些MP4格式视频在ipad qqHD上会出现以下bug:

* 视频全屏播放会提前2秒结束

于是，搞个demo吧，拷了个播放没问题的视频和有问题的视频用纯video标签试了一下，结果：正常的视频还是正常，有问题的视频还是提前2秒结束；（看来videojs是无辜的，看样子是视频的锅了）

好了，让压缩视频的人看看这两个视频是怎么压缩的，有啥子区别。结果。。。。。都是同一个妈生的。

好了，继续找问题，后来发现 优酷、腾讯视频等都会被浏览器劫持，产生双层播放器问题，并且。。。提前2秒结束。好了，自家视频都有问题，这锅是腾讯了的，qqHD版本号6.9.1.1019。

![]( "")

但浏览各网站视频接着发现有些视频并不会被QQ浏览器所劫持，于是想这是QQHD视频播放器的一个bug，要是不用该播放器会不会解决这个问题呢；浏览器应该是在视频加载完成后检查是否有video标签来判断的，在测了几个demo后发现在网页加载后页面就会出现被劫持的标志，也就是左侧那块区域。

那就在网页加载后创建video标签试试。

	window.onload = function(){
		myFunction()
	}
     function myFunction() {
        var x = document.createElement("VIDEO");
        x.setAttribute("src","f.mp4");
        x.setAttribute("width", "520");
        x.setAttribute("height", "240");
        x.setAttribute("controls", "controls");
        document.body.appendChild(x);
        x.play()
      }

结果好像不好使。。
难道浏览器检查video标签比执行函数慢？
那就来个延迟吧。

	window.onload = function(){
	  setTimeout(function(){
	    myFunction()
	  },500);
	}

结果发现还真的好使。。。。

