# HZBannerViewDemo
## 轮播图

![示例图片](http://upload-images.jianshu.io/upload_images/2764759-f64546efd505f504.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
# 使用方法
0.导入文件夹`HZBannerView`

1.导入类 
`#import "HZBannerView.h"`

2.使用代码示例
```
GFloat width = self.view.bounds.size.width;
HZBannerView *banner = [[HZBannerView alloc] initWithFrame:CGRectMake(0, 64, width, width)];
banner.models = models;
[self.view addSubview:banner];
```
>注意:这里的models为`NSArray<HZBannerModel *> *`类型,使用时候自己转换下模型即可,示例可见GitHubDemo

3.如需监听轮播图点击,只需设置代理
`banner.delegate = self;`
遵守`<HZBannerViewDelegate>`协议

实现`-(void)HZBannerView:(HZBannerView *)bannerView didSelectedAt:(NSInteger)index;`方法即可
