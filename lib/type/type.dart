import 'package:flutter/material.dart';

class ApiResult<T> {
  bool succeed;
  T resultValue;
  int errorCode;
  String errorMessage;
}

class Product {
  Product(
      {this.productId,
      this.categoryId = 0,
      this.name,
      this.price,
      this.colorCode,
      this.deleted = false});

  Product.fromMap(Map<String, dynamic> map) {
    productId = map['productId'] as int;
    categoryId = map['categoryId'] as int;
    name = map['name'] as String;
    price = map['price'] as int;
    colorCode = map['colorCode'] as int;
    deleted = (map['deleted'] as int) == 1;
  }

  int productId;
  int categoryId; // 未使用
  String name;
  int price;
  int colorCode;
  bool deleted;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'productId': productId,
      'categoryId': categoryId,
      'name': name,
      'price': price,
      'colorCode': colorCode,
      'deleted': deleted ? 1 : 0,
    };
  }
}

class Order {
  Order(
      {this.orderId,
      this.billingAmount,
      this.depositAmount,
      this.discount,
      this.tax,
      this.year,
      this.month,
      this.day,
      this.hour,
      this.sinceEpoch});

  Order.fromMap(Map<String, dynamic> map) {
    orderId = map['orderId'] as int;
    billingAmount = map['billingAmount'] as int;
    depositAmount = map['depositAmount'] as int;
    discount = map['discount'] as int;
    tax = map['tax'] as double;
    year = map['year'] as int;
    month = map['month'] as int;
    day = map['day'] as int;
    hour = map['hour'] as int;
    sinceEpoch = map['sinceEpoch'] as int;
  }

  int orderId;
  int billingAmount;
  int depositAmount;
  int discount;
  double tax;
  int year;
  int month;
  int day;
  int hour;
  int sinceEpoch;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'orderId': orderId,
      'billingAmount': billingAmount,
      'depositAmount': depositAmount,
      'discount': discount,
      'tax': tax,
      'year': year,
      'month': month,
      'day': day,
      'hour': hour,
      'sinceEpoch': sinceEpoch,
    };
  }
}

class Sales {
  const Sales({
    this.orderId,
    this.productId,
    this.price,
    this.quantity,
    this.sinceEpoch,
  });

  final int orderId;
  final int productId;
  final int price;
  final int quantity;
  final int sinceEpoch;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'orderId': orderId,
      'productId': productId,
      'price': price,
      'quantity': quantity,
      'sinceEpoch': sinceEpoch,
    };
  }
}

class OrderItem {
  OrderItem({this.product, this.quantity});

  Product product;
  int quantity;
}

class OrderInfo {
  List<OrderItem> items = <OrderItem>[];
  int billingAmount = 0;
  int depositAmount = 0;
  int discount = 0;
}

class SalesChartInfo {
  const SalesChartInfo({this.year, this.month, this.day, this.sum});

  final int year;
  final int month;
  final int day;
  final int sum;
}
