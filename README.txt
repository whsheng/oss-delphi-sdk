软件名称：OSS Delphi SDK
软件类型：代码类库
软件版本：1.0.0
编程语言：Delphi/Object Pascal
编译平台：Delphi XE3 试用版
软件授权：MIT许可证
联系方式：menway@gmail.com

详细说明：
==================================================================================
该SDK使用Delphi/Object Pascal编程语言编写，完整实现了阿里云OSS API的全部功能，并提
供了两套API：第一套API（类名：TAliOss）仿照OSS PHP SDK实现了全部函数，第二套API（
类名：TAliOssFileSystem）封装了TAliOss，并在其的基础上实现了类似于文件系统的API，
实现了包括“卷”、“文件夹”、“文件”等抽象概念，并提供相应的功能函数。

两套API面向的应用场景不同：TAliOssFileSystem适合于将OSS服务看作是一种文件系统的应
用，开发人员不必了解OSS API的内部参数及XML定义，可提高编程效率，使用方便；TAliOSS
适合于其他类型的应用，当编程人员需要更加定制化的调用或者需要更加灵活的参数设置时，
可以直接使用该SDK操作调用参数和返回值。两套API互不干扰，可以在项目中同时使用。