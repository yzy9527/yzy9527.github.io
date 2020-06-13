---
title: js-canvas实现图片压缩
date: 2020-6-2 20:42:27
categories:
 - JavaScript
---

前端项目中经常会碰到一些展示图片的地方，比如轮播图、头像上传等;对于这些场景，比如轮播图需要的图片为1000*500，但用户可能会上传尺寸为2000*1000大小的图片，这不仅会影响文件上传的速度又浪费了服务器资源；

本文就对`js图片压缩`做一些总结

### 目标：

 - 将压缩后图片大小控制在800*800内
 - 小于800*800的不进行压缩

先来看张效果图
![](https://qiniu.xiaoxilao.com/js-compress.png)

上面展示中将一张`1244*700`的图片经过压缩后变成了`800*450`，图片大小从`307k`变成了`84k`

 <!--more-->
首先在`html`中搞一个上传按钮

```html
<input type="file" id="upload">
```
接下来对上传按钮进行监听

```js
const acceptType = ['image/jpg', 'image/jpeg']
const MAXSIZE = 1024 * 1024
const MAXSIZE_STR = '1MB'


const upload = document.getElementById('upload')

upload.addEventListener('change', function (e) {
    const [file] = e.target.files
    // console.log(e)
    if (!file) {
        return
    }
    const {type: fileType, size: fileSize} = file
    //检查图片类型
    if (acceptType.indexOf(fileType) < 0) {
        alert(`不支持[${fileType}]文件类型`)
        return
    }
    //检查文件大小
    if (fileSize > MAXSIZE) {
        alert(`文件超出${MAXSIZE_STR}!`)
        upload.value = ''
        return
    }
    //转base64
    convertImgToBase64(file)
})
```
这里对图片允许上传的最大值设定为了`1MB`；上传前检查文件类型和图片大小，以便后续操作

获取到图片文件后，利用[FileReader](https://developer.mozilla.org/zh-CN/docs/Web/API/FileReader "FileReader")将图片转为`base64`

```js
function convertImgToBase64(file) {
    let reader = new FileReader()
    //readAsDataURL 方法会读取指定的 Blob 或 File 对象
    reader.readAsDataURL(file);
    reader.addEventListener('load', function (e) {
        const base64Imgage = e.target.result
        // const base64Imgage = reader.result
        // console.log(base64Imgage)
        
        compress(base64Imgage)
        reader = null
    })
}
```

获取到`base64`后

首先设定宽高

```js
    let maxW = 800
    let maxH = 800
```
创建`image`对象，获取上传图片的宽高

```js
    const image = new Image()
    image.src = base64Imgage
```
当image加载完成后将`maxW`和`image`的宽度进行比较
如果实际宽度大于`maxW`则进行压缩,并计算出压缩比，然后设定`maxH`

以原图`1244*700`为例，`ratio = 1244 / 800` 等于`1.555`，
则`maxH`为`450`,故计算后的图片大小为 `800*450`

```js
let ratio //图片压缩比
let needCompress = false //是否需要压缩
if (maxW < image.naturalWidth) {
    needCompress = true
    ratio = image.naturalWidth / maxW
    maxH = image.naturalHeight / ratio
}
```
此时再对高度做相同的处理即可将图片大小设定在`800*800`内
 
获取压缩后的图片大小后，在利用canvas进行绘制，将canvas的宽高分别设置为`maxW` `maxH`

```js
const canvas = document.createElement('canvas')
canvas.setAttribute('id','__compress__')
//设置宽高
canvas.width = maxW
canvas.height = maxH
canvas.style.visibility = 'hidden'
//获取执行上下文
const ctx = canvas.getContext('2d')
//清空矩形内所有内容
ctx.clearRect(0,0,maxW,maxH)
 //开始绘制图片
ctx.drawImage(image,0,0,maxW,maxH)

//在指定图片格式和图片质量
const compressImage = canvas.toDataURL('image/jpeg',0.9)

//上传
uploadToServer(compressImage)
```
 > canvas.toDataURL(type, encoderOptions); encoderOptions :在指定图片格式为 image/jpeg 或 image/webp的情况下，可以从 0 到 1 的区间内选择图片的质量。如果超出取值范围，将会使用默认值 0.92。其他参数会被忽略;若使用image/png还可能让图片变大
 
获取base64图片

```js
function uploadToServer(compressImage) {
    //base64
    console.log('上传到服务器...',compressImage)
}
```
 
完整代码

```js
function compress(base64Imgage) {
    // console.log(base64Imgage)
    let maxW = 800
    let maxH = 800
    const image = new Image()
    image.addEventListener('load', function () {
        let ratio //图片压缩比
        let needCompress = false //是否需要压缩
        // console.log(image.naturalWidth, image.naturalHeight)
        if (maxW < image.naturalWidth) {
            needCompress = true
            ratio = image.naturalWidth / maxW
            maxH = image.naturalHeight / ratio
        }
        if (maxH < image.naturalHeight) {
            needCompress = true
            ratio = image.naturalHeight / maxH
            maxW = image.naturalWidth / ratio
        }
        //不需要压缩
        if (!needCompress){
            maxW = image.naturalWidth
            maxH = image.naturalHeight
        }
        console.log('ratio',ratio)
        const canvas = document.createElement('canvas')
        canvas.setAttribute('id','__compress__')
        canvas.width = maxW
        canvas.height = maxH
        canvas.style.visibility = 'hidden'
        
        const ctx = canvas.getContext('2d')
        ctx.clearRect(0,0,maxW,maxH)//清空矩形内所有内容
        ctx.drawImage(image,0,0,maxW,maxH)
        const compressImage = canvas.toDataURL('image/jpeg',0.9)
        uploadToServer(compressImage)

        const _image = new Image()
        _image.src = compressImage
        document.body.appendChild(_image)
        canvas.remove()
        console.log(`压缩比：${image.src.length/_image.src.length}`)
    })
    image.src = base64Imgage
}
```
### 总结

1. 通过`input file`上传图片，使用`FileReader`读取上传的图片数据
2. 将图片数据传给`image`,然后使用canvas绘制图片，调用`canvas.toDataURL`,进行压缩
3. 获取压缩后的`base64`格式的图片数据
