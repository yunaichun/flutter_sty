import 'package:flutter/material.dart';

/* 下拉刷新、上拉加载【https://github.com/xuelongqy/flutter_easyrefresh/】 */
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_footer.dart';
import 'package:flutter_easyrefresh/material_header.dart';

/* 添加 provide 状态管理【https://github.com/google/flutter-provide】 */
import 'package:provide/provide.dart';
import 'package:flutter_study/src/provide/category.dart';

/* 屏幕适配：https://github.com/OpenFlutter/flutter_screenutil */
import 'package:flutter_screenutil/flutter_screenutil.dart';

/* 将 json 对象转换为 dart 对象：json.decode */
import 'dart:convert';
/* 数据格式 */
import '../../types/category.type.dart';
import '../../types/goods.type.dart';
/* 数据请求 */
import '../../service/category.dart';


class GoodsWidget extends StatefulWidget {
  GoodsWidget({Key key}) : super(key: key);

  @override
  _GoodsWidgetState createState() => _GoodsWidgetState();
}

class _GoodsWidgetState extends State<GoodsWidget> {

  // 获取商品数据【使用可选参数】
  _getMallGoods() {
    var page = Provide.value<CategoryProvider>(context).page;
    var categoryIndex = Provide.value<CategoryProvider>(context).categoryIndex;
    var categorySubIndex = Provide.value<CategoryProvider>(context).categorySubIndex;
    List<CategoryData> categoryList = Provide.value<CategoryProvider>(context).categoryList;
    var formData = {
      'categoryId': categoryList[categoryIndex].mallCategoryId,
      // categorySubIndex 为 0 代表 "全部"【这是一个坑，数据不一致为题：index.dart 文件中 categoryList 没有将二级分类 “全部” 添加】
      'categorySubId': categorySubIndex == 0 ? '' : categoryList[categoryIndex].bxMallSubDto[categorySubIndex].mallSubId,
      'page': page
    };
    getMallGoods(formData: formData).then((res) {
      // 这里需要用 json.decode , 不然会报错，因为定义的字段含有 dynamic 类型
      GoodsResponse response = new GoodsResponse.fromJson(json.decode(res));
      /* 一、添加商品 */
      List<GoodsData> goodsList = Provide.value<CategoryProvider>(context).goodsList;
      goodsList.addAll(response.data);
      Provide.value<CategoryProvider>(context).setGoodsList(goodsList);
      /* 二、更改 page */
      Provide.value<CategoryProvider>(context).addPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().setWidth(570) ,
      height: ScreenUtil().setHeight(1000),
      child: Provide<CategoryProvider>(
        builder: (context, child, category) {
          if (category.goodsList.length != 0) {
            return EasyRefresh(
              child: ListView.builder(
                itemCount: category.goodsList.length,
                itemBuilder: (context, index) {
                  return _GoodItem(category.goodsList, index);
                },
              ),
              onLoad: () async {
                print('onLoad 上拉事件');
                await _getMallGoods();
              },
              onRefresh: () async {
                print('onRefresh 下滑事件');
                // await _getMallGoods();
              },
              header: MaterialHeader(),
              footer: MaterialFooter(),
            );
          } else {
            return Text('暂无数据');
          }
        })
    );
  }

  Widget _GoodItem(List<GoodsData> list, int index) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.only(top: 5.0,bottom: 5.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(width: 1.0,color: Colors.black12)
          )
        ),
        child: Row(
          children: <Widget>[
            _imageWidget(list, index),
            Column(
              children: <Widget>[
                _goodsName(list, index),
                _goodsPrice(list, index)
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _imageWidget(List<GoodsData> list, int index) {
    return Container(
      width: ScreenUtil().setWidth(200),
      child: Image.network(list[index].image),
    );
  }

  Widget _goodsName(List<GoodsData> list, int index) {
    return Container(
      padding: EdgeInsets.all(5.0),
      width: ScreenUtil().setWidth(370),
      child: Text(
        list[index].goodsName,
        // 最大两行，超出省略号
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: ScreenUtil().setSp(28)),
      ),
    );
  }

  Widget _goodsPrice(List<GoodsData> list, int index) {
    return Container(
      margin: EdgeInsets.only(top:20.0),
      width: ScreenUtil().setWidth(370),
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 5.0, right: 20.0),
            child:Text(
              '价格:￥${list[index].presentPrice}',
              style: TextStyle(
                color:Colors.pink,
                fontSize:ScreenUtil().setSp(30)
              ),
            ),
          ),
          Text(
            '￥${list[index].oriPrice}',
            style: TextStyle(
              color: Colors.black26,
              // 水平下划线
              decoration: TextDecoration.lineThrough
            ),
          )
        ],
      ),
    );
  }

}
